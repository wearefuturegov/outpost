class Service < ApplicationRecord

  include HasSnapshots

  belongs_to :organisation, counter_cache: true

  has_many :snapshots

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
  after_save :update_service_at_locations
  after_save :notify_watchers
  before_save :recursively_add_parents

  # sort scopes
  scope :oldest, ->  { order("updated_at ASC") }
  scope :newest, ->  { order("updated_at DESC") }
  scope :alphabetical, ->  { order(name: :ASC) }
  scope :reverse_alphabetical, ->  { order(name: :DESC) }

  # filter scopes
  scope :in_taxonomy, -> (id) { joins(:taxonomies).where("taxonomies.id in (?)", id)}
  scope :scheduled, -> { where("visible_from > (?)", Date.today)}
  scope :hidden, -> { where("visible_to < (?)", Date.today)}

  acts_as_taggable_on :labels

  paginates_per 20
  validates_presence_of :name

  include Discard::Model

  include PgSearch::Model
  pg_search_scope :search, 
    against: [:id, :name, :description], 
    using: {
      tsearch: { prefix: true }
    }

  def display_name
    self.name || "Unnamed service"
  end

  def status
    if discarded?
      "archived"
    elsif !approved
      "pending"
    elsif !visible
      "invisible"
    elsif (visible_from.present? && (visible_from > Date.today))
      "scheduled"      
    elsif (visible_to.present? && (visible_to < Date.today))
      "expired"
    else
      "active"
    end
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
    self.snapshot_action = "archive"
    self.discard
  end

  def restore
    self.snapshot_action = "unarchive"
    self.undiscard
  end

  def approve
    self.snapshot_action = "approve"
    self.approved = true
    self.save
  end

  def update_service_at_locations
    self.service_at_locations.each do |service_at_location|
      service_at_location.update_service_fields
    end
  end

  def notify_watchers
    ServiceMailer.with(service: self).notify_watchers_email.deliver_later
  end

  def recursively_add_parents
    # self.taxonomies.each do |t|
    #   self.taxonomies << t.ancestors
    # end
  end

  # return the most recent approved snapshot, if it exists
  def last_approved_snapshot
    Snapshot
      .where(service: self.id)
      .where("object->>'approved' = 'true'")
      .order(created_at: :desc)
      .first
  end

  # include nested taxonomies in json representation by default
  def as_json(options={})
    options[:include] = [
      :taxonomies, 
      :locations,
      :contacts,
      :cost_options,
      :local_offer,
      :regular_schedules
    ]
    super
  end

  def unapproved_changes?(attribute, child_attribute = false)
    if self.approved?
      false
    else
      if(child_attribute)
        self.as_json[attribute][child_attribute].to_s != self.last_approved_snapshot.object[attribute][child_attribute].to_s
      else
        self.as_json[attribute].to_s != self.last_approved_snapshot.object[attribute].to_s
      end
    end
  end

  def unapproved_changes_array?(attribute)
    if self.approved?
      false
    else
      self.as_json[attribute].to_a.sort_by{ |o| o["id"]} != self.last_approved_snapshot.object[attribute].to_a.sort_by{ |o| o["id"]}
    end
  end

end