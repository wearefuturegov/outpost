class ServiceAtLocationSearchItem < ApplicationRecord
  geocoded_by :location_postal_code, latitude: :location_latitude, longitude: :location_longitude

  belongs_to :service
  belongs_to :location
  has_one :organisation, through: :service

  paginates_per 20
end