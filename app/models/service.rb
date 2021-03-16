class Service < ApplicationRecord

  include MongoIndexCallbacks
  include Discard::Model
  include NormalizeBlankValues

  has_paper_trail(
    meta: {
      object: proc { |s| s.as_json },
      object_changes: proc { |s| s.saved_changes.as_json }
    }
  )

  # associations
  belongs_to :organisation, counter_cache: true

  belongs_to :ofsted_item, required: false

  has_and_belongs_to_many :send_needs

  has_many :snapshots

  has_many :links
  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: :all_blank

  has_many :meta, class_name: "ServiceMeta"
  accepts_nested_attributes_for :meta

  has_many :cost_options
  accepts_nested_attributes_for :cost_options, allow_destroy: true, reject_if: :all_blank

  has_many :regular_schedules
  accepts_nested_attributes_for :regular_schedules, allow_destroy: true, reject_if: :all_blank

  has_one :local_offer
  accepts_nested_attributes_for :local_offer, allow_destroy: true

  has_many :contacts  
  accepts_nested_attributes_for :contacts, allow_destroy: true, reject_if: :all_blank

  has_many :phones, through: :contacts
  accepts_nested_attributes_for :phones

  has_many :feedbacks

  has_many :service_taxonomies
  has_many :taxonomies, through: :service_taxonomies

  has_many :watches
  has_many :users, through: :watches

  has_many :notes

  has_many :service_at_locations
  has_many :locations, through: :service_at_locations
  accepts_nested_attributes_for :locations, allow_destroy: true, reject_if: :all_blank

  # callbacks
  after_save :notify_watchers
  before_save :recursively_add_parents
  before_save :skip_nested_indexes

  filterrific(
    default_filter_params: { sorted_by: "recent" },
    available_filters: [
      :sorted_by,
      :in_taxonomy,
      :with_status,
      :tagged_with,
      :search
    ]
  )

  # scopes
  scope :ofsted_registered, ->  { where.not(ofsted_item_id: nil) }

  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? "desc" : "asc"
    case sort_option.to_s
    when /^recent/
      order("services.updated_at desc")
    when /^name_/
      order("LOWER(services.name) #{direction}")
    when /^created_at_/
      order("services.created_at #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :in_taxonomy, -> (id) { 
    joins(:taxonomies).where("taxonomies.id in (?)", id)
  }
  
  scope :with_status, -> (status) {
    case status
    when "scheduled"
      where("visible_from > (?)", Date.today)
    when "expired"
      where("visible_to < (?)", Date.today)
    when "invisible"
      where("visible != true")
    when "closed"
      where("temporarily_closed = true")
    else
      raise(ArgumentError, "Invalid status: #{status}")
    end
  }

  acts_as_taggable_on :labels
  paginates_per 20

  # validations
  validates_presence_of :name
  validates_uniqueness_of :name
  validates :name, length: { minimum: 2 }
  validates :name, length: { maximum: 100 }
  validate :validate_ages
  validate :validate_freeness

  def self.options_for_status
    [
      ["All statuses", ""],
      ["Only scheduled", "scheduled"],
      ["Only expired", "expired"],
      ["Only invisible", "invisible"],
      ["Only temporarily closed", "closed"]
    ]
  end

  def self.options_for_sorted_by
    [
      ["Recently updated", "recent"],
      ["A-Z", "name_asc"],
      ["Z-A", "name_desc"],
      ["Oldest added", "created_at_asc"],
      ["Newest added", "created_at_desc"],
    ]
  end

  def self.options_for_labels
    ActsAsTaggableOn::Tag.most_used.map { |t| [t.name, t.name] }.unshift(["All labels", ""])
  end

  def validate_ages
    if min_age.present? && max_age.present? && min_age > max_age
      errors.add(:base, "The maximum age can't be less than the minimum age")
    end
  end

  def validate_freeness
    if cost_options.any? && free
      errors.add(:base, "Free services can't have any fees")
    end
  end

  include PgSearch::Model
  pg_search_scope :search, 
    against: [:id, :name, :description], 
    using: {
      tsearch: { prefix: true }
    }, 
    associated_against: {
      locations: [:postal_code],
      meta: [:value]
    }

  def display_name
    self.name || "Unnamed service"
  end

  def in_taxonomy?(id)
    taxonomies.where("taxonomies.id in (?)", id).exists?
  end

  def status
    if !approved
      "pending"
    elsif marked_for_deletion?
      "marked for deletion"
    elsif discarded?
      "archived"
    elsif !visible
      "invisible"
    elsif (visible_from.present? && (visible_from > Date.today))
      "scheduled"      
    elsif (visible_to.present? && (visible_to < Date.today))
      "expired"
    elsif temporarily_closed
      "temporarily closed"
    else
      "active"
    end
  end

  def ofsted_registered?
    ofsted_item_id != nil
  end

  def open_today?
    regular_schedules.exists?(weekday: Date.today.cwday)
  end

  def open_weekends?
    regular_schedules.exists?(weekday: [6,7])
  end

  def open_after_six?
    regular_schedules.where("closes_at > ?", Time.parse("18:00")).exists?
  end

  # custom actions with paper trail events
  def archive
    self.paper_trail_event = "archive"
    self.discard
  end

  def restore
    self.paper_trail_event = "restore"
    self.marked_for_deletion = nil
    self.undiscard
  end

  def approve
    self.paper_trail_event = "approve"
    self.approved = true
    self.save
  end

  # callbacks
  def notify_watchers
    ServiceMailer.with(service: self).notify_watchers_email.deliver_later
  end

  def recursively_add_parents
    self.taxonomies.each do |t|
      self.taxonomies << t.ancestors
    end
    self.taxonomies = self.taxonomies.uniq
  end

  def skip_nested_indexes
    (self.taxonomies + self.locations + [self.organisation]).each {|t| t.skip_mongo_callbacks = true }
  end

  # include nested taxonomies in json representation by default
  def as_json(options={})
    options[:include] = {
      :organisation => {},
      :locations => { 
        methods: :geometry,
        include: :accessibilities
       },
      :taxonomies => { methods: :slug },
      :meta => {},
      :contacts => {},
      :local_offer => {},
      :send_needs => {},
      :cost_options => {},
      :regular_schedules => {}
    }
    super
  end

  # fields that we don't care about for versioning purposes
  def ignorable_fields
    ["created_at", "updated_at", "approved", "discarded_at", "organisation", "notes_count"]
  end

  # return the most recent approved snapshot, if it exists
  def last_approved_snapshot
    self.versions
      .where("object->>'approved' = 'true'")
      .reorder(created_at: :desc)
      .first
  end

  def unapproved_fields
    changed_fields = []
    last_approved_version = last_approved_snapshot
    self.as_json.each do |key, value|
      # eql? lets us do a slightly more intelligent comparison than simple "===" equality
      unless value.eql?(last_approved_version.object[key])
        # we don't care about these fields
        unless ignorable_fields.include?(key)
          changed_fields << key
        end
      end
    end
    changed_fields
  end

  def unapproved_changes?(attribute)
    unless self.approved?
      if last_approved_snapshot.present?
        !self.as_json[attribute].eql?(last_approved_snapshot.object[attribute])
      end
    end
  end

  def publicly_visible?
    visible && discarded_at.nil?
  end
end