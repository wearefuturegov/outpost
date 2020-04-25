class Service < ApplicationRecord
  belongs_to :organisation

  has_one :contact
  has_many :service_at_locations
  has_many :locations, through: :service_at_locations

  has_many :service_taxonomies
  has_many :taxonomies, through: :service_taxonomies

  has_and_belongs_to_many :send_needs

  # watch functionality
  has_many :watches
  has_many :users, through: :watches

  has_many :notes

  after_save :update_service_at_locations
  after_save :notify_watchers

  accepts_nested_attributes_for :locations,
    :reject_if => proc {|attributes|
      attributes.all? {|k,v| v.blank?}
    }

  # sort scopes
  scope :oldest, ->  { order("updated_at ASC") }
  scope :newest, ->  { order("updated_at DESC") }
  scope :alphabetical, ->  { order("name ASC") }
  scope :reverse_alphabetical, ->  { order("name DESC") }

  # filter scopes
  scope :in_taxonomy, -> (id) { joins(:taxonomies).where("taxonomies.id in (?)", id)}
  scope :scheduled, -> { where("visible_from > (?)", Date.today)}
  scope :hidden, -> { where("visible_to < (?)", Date.today)}

  paginates_per 20
  validates_presence_of :name

  has_paper_trail ignore: [:created_at, :updated_at, :discarded_at, :approved]

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
      "hidden"
    else
      "active"
    end
  end

  # custom actions with paper trail events
  def archive
    self.paper_trail_event = 'archive'
    self.discard
    self.paper_trail.save_with_version
  end

  def restore
    self.paper_trail_event = 'restore'
    self.undiscard
    self.paper_trail.save_with_version
  end

  def approve
    self.paper_trail_event = 'approve'
    self.approved = true
    self.save
    self.paper_trail.save_with_version
  end

  def update_service_at_locations
    self.service_at_locations.each do |service_at_location|
      service_at_location.update_service_fields
    end
  end

  def notify_watchers
    ServiceMailer.with(service: self).notify_watchers_email.deliver_later
  end
end