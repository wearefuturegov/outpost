class ServiceAtLocation < ApplicationRecord
  belongs_to :service
  belongs_to :location

  geocoded_by :postcode
  has_one :organisation, through: :service
  paginates_per 20
end