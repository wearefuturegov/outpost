class PostcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    ukpc = UKPostcode.parse(value)
    unless ukpc.full_valid?
      record.errors[attribute] << "doesn't seem to be valid. Please check it and try again."
    end
  end
end

class Location < ApplicationRecord
  has_many :service_at_locations
  has_many :services, through: :service_at_locations
  has_and_belongs_to_many :accessibilities

  # validates :postal_code, presence: true, postcode: true

  before_validation :geocode
  geocoded_by :postal_code
  after_save :update_service_at_locations

  paginates_per 20

  # def postal_code=(str)
  #   super UKPostcode.parse(str).to_s
  # end

  # filter scopes
  scope :only_with_services, ->  { joins(:services) }
  scope :only_without_services, ->  { left_joins(:service_at_locations).where(service_at_locations: {id: nil}) }

  include PgSearch::Model
  pg_search_scope :search, 
    against: [:id, :name, :address_1, :city, :postal_code, :state_province], 
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

  def one_line_address
    array = []
    array.push(name) if name.present?
    array.push(address_1) if address_1.present?
    array.push(city) if city.present?
    array.push(postal_code) if postal_code.present?
    array.join(", ")
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

  def checkbox_attributes
    {
      name: display_name,
      one_line_address: one_line_address
    }
  end

end