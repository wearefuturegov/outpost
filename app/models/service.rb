class Service < ApplicationRecord

  include HasSnapshots

  belongs_to :organisation, counter_cache: true

  has_many :snapshots

  has_many :contacts
  has_many :phones, through: :contacts

  accepts_nested_attributes_for :contacts, allow_destroy: true
  accepts_nested_attributes_for :phones

  has_many :feedbacks

  has_many :service_at_locations
  has_many :locations, through: :service_at_locations

  has_many :service_taxonomies
  has_many :taxonomies, through: :service_taxonomies

  has_and_belongs_to_many :send_needs

  has_many :watches
  has_many :users, through: :watches

  has_many :notes

  after_save :update_service_at_locations
  after_save :notify_watchers
  before_save :recursively_add_parents

  accepts_nested_attributes_for :locations, allow_destroy: true,
    :reject_if => proc {|attributes|
      attributes.all? {|k,v| v.blank?}
    }

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
    against: [:name, :description], 
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
    elsif (visible_from.present? && (visible_from > Date.today))
      "scheduled"      
    elsif (visible_to.present? && (visible_to < Date.today))
      "expired"
    else
      "active"
    end
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
    self.taxonomies.each do |t|
      self.taxonomies << t.ancestors
    end
  end
end