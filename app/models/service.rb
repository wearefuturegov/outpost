class Service < ApplicationRecord
  belongs_to :organisation
  has_one :contact
  has_many :service_at_locations
  has_many :locations, through: :service_at_locations

  paginates_per 20
  validates_presence_of :name
end