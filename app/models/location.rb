class Location < ApplicationRecord
  has_many :service_at_locations
  has_many :services, through: :service_at_locations
  has_and_belongs_to_many :accessibilities

  validates :postal_code, presence: true
  validate :postal_code_is_valid

  before_validation :geocode
  geocoded_by :postal_code

  paginates_per 20

  attr_accessor :skip_mongo_callbacks
  after_save :update_index, unless: :skip_mongo_callbacks

  def postal_code_is_valid
    parsed = UKPostcode.parse(postal_code)
    unless parsed.full_valid?
      errors.add(:base, :invalid_postcode)
    end
  end

  scope :alphabetical, ->  { order(name: :ASC) }
  scope :reverse_alphabetical, ->  { order(name: :DESC) }

  # filter scopes
  scope :only_with_services, ->  { joins(:services) }
  scope :only_without_services, ->  { left_joins(:service_at_locations).where(service_at_locations: {id: nil}) }

  include PgSearch::Model
  pg_search_scope :search, 
    against: [:id, :name, :address_1, :city, :postal_code, :state_province], 
    using: {
      tsearch: { prefix: true }
    }

  def display_name
    if name.present?
      name
    elsif address_1.present?
      address_1
    else
      "Unnamed location #{id}"
    end
  end

  def one_line_address
    array = []
    array.push(name) if name.present?
    array.push(address_1) if address_1.present?
    array.push(city) if city.present?
    array.push(postal_code) if postal_code.present?
    array.join(", ")
  end

  def geometry
    {
      type: "Point",  
      coordinates: [longitude.to_f, latitude.to_f]
    }
  end

  private

  def should_geocode?
    postcode_changed_or_lat_long_blank && Rails.env.production?
  end

  def postcode_changed_or_lat_long_blank
    postal_code_changed? || latitude.blank? || longitude.blank?
  end

  def checkbox_attributes
    {
      name: display_name,
      one_line_address: one_line_address
    }
  end

  def update_index
    UpdateIndexLocationsJob.perform_later(self)
  end
end