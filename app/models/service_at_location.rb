class ServiceAtLocation < ApplicationRecord
  belongs_to :service
  belongs_to :location

  geocoded_by :postcode
  has_one :organisation, through: :service
  paginates_per 20

  after_create :set_fields
  has_many :contacts, through: :service
  has_many :taxonomies, through: :service

  scope :in_taxonomies, -> (taxonomies) {
    query = taxonomies.map{|e| e.titleize.downcase }
    matching_services = Service.joins(:taxonomies).group(:id)
        .where("lower(taxonomies.name) in (?)", query)
        .having('count(distinct taxonomy_id) = ?', taxonomies.length)
        .select(:id)

    where(:service_id => matching_services)
  }

  include Discard::Model

  def set_fields
    update_service_fields
    update_location_fields
  end

  def update_service_fields
    self.service_name = service.name
    self.service_description = service.description
    self.service_url = service.url
    # self.service_email = service.email
    self.discarded_at = service.discarded_at
    self.save
  end

  def update_location_fields
    self.postcode = location.postal_code
    self.latitude = location.latitude
    self.longitude = location.longitude
    self.save
  end
end