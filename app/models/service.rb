class Service < ApplicationRecord
  belongs_to :organisation

  has_one :contact
  has_many :service_at_locations
  has_many :locations, through: :service_at_locations

  has_many :service_taxonomies
  has_many :taxonomies, through: :service_taxonomies

  # watch functionality
  has_many :watches
  has_many :users, through: :watches
  
  has_many :notes

  # sort scopes
  scope :oldest, ->  { order("updated_at ASC") }
  scope :newest, ->  { order("updated_at DESC") }
  scope :alphabetical, ->  { order("name ASC") }
  scope :reverse_alphabetical, ->  { order("name DESC") }

  paginates_per 20
  validates_presence_of :name

  acts_as_approval_resource
  has_paper_trail ignore: [:created_at, :updated_at, :discarded_at]

  include Discard::Model

  include PgSearch::Model
  pg_search_scope :search, 
    against: [:name, :description], 
    using: {
      tsearch: { prefix: true }
    }

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |result|
        csv << result.attributes.values_at(*column_names)
      end
    end
  end

  def display_name
    self.name || "Unnamed service"
  end

  def status
    if discarded?
      "Archived"
    else
      "Active"
    end
  end
end