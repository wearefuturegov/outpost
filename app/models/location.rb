class Location < ApplicationRecord
  has_many :service_at_locations
  has_many :services, through: :service_at_locations

  geocoded_by :postal_code
  #after_validation :geocode, if: :postcode_changed_or_lat_long_blank

  private

  def postcode_changed_or_lat_long_blank
    (postal_code_changed? || latitude.blank? || longitude.blank?) && not_test
  end

  def not_test
    !Rails.env.test?
  end
end