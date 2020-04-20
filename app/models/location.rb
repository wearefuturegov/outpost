class Location < ApplicationRecord
  has_many :service_at_locations
  has_many :services, through: :service_at_locations

  geocoded_by :postal_code
  after_validation :geocode, if: :should_geocode?

  private

  def should_geocode?
    postcode_changed_or_lat_long_blank && Rails.env.production?
  end

  def postcode_changed_or_lat_long_blank
    postal_code_changed? || latitude.blank? || longitude.blank?
  end

end