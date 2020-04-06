class Location < ApplicationRecord
  has_many :service_at_locations
  has_many :services, through: :service_at_locations

  geocoded_by :postal_code
  after_validation :geocode
end