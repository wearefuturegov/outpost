class Location < ApplicationRecord
  has_many :service_at_locations
  has_many :services, through: :service_at_locations

  geocoded_by :postal_code
  after_validation :geocode, if: :should_geocode?
  after_save :update_service_at_locations

  validates_presence_of :postal_code

  paginates_per 20

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