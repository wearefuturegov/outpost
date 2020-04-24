class Location < ApplicationRecord
  has_many :service_at_locations
  has_many :services, through: :service_at_locations
  has_and_belongs_to_many :accessibilities

  geocoded_by :postal_code
  after_validation :geocode, if: :should_geocode?
  after_save :update_service_at_locations

  #validates_presence_of :postal_code

  paginates_per 20

  # filter scopes
  scope :only_with_services, ->  { joins(:services) }
  scope :only_without_services, ->  { left_joins(:service_at_locations).where(service_at_locations: {id: nil}) }

  include PgSearch::Model
  pg_search_scope :search, 
    against: [:name, :address_1, :city, :postal_code, :state_province], 
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

  private

  def should_geocode?
    postcode_changed_or_lat_long_blank && Rails.env.production?
  end

  def postcode_changed_or_lat_long_blank
    postal_code_changed? || latitude.blank? || longitude.blank?
  end

  def update_service_at_locations
    self.service_at_locations.each do |service_at_location|
      service_at_location.update_location_fields
    end
  end

end