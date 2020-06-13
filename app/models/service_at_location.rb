class ServiceAtLocation < ApplicationRecord
  belongs_to :service
  belongs_to :location

  has_one :organisation, through: :service
  paginates_per 20

  has_many :contacts, through: :service
  has_many :taxonomies, through: :service
end