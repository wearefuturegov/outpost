class ServiceAtLocation < ApplicationRecord
  belongs_to :service
  belongs_to :location

  geocoded_by :postcode
  has_one :organisation, through: :service
  paginates_per 20

  def update_service_fields
    self.service_name = service.name
    self.service_description = service.description
    self.service_url = service.url
    self.service_email = service.email
    self.save
  end

  def update_location_fields
    self.postcode = location.postal_code
    self.latitude = location.latitude
    self.longitude = location.longitude
    self.save
  end
end