class Location < ApplicationRecord
  has_one :physical_address
  has_many :service_at_locations
  has_many :services, through: :service_at_locations
end