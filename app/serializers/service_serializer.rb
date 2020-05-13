class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :url, :email

  has_many :locations
  has_many :contacts
  belongs_to :organisation
  has_many :taxonomies
end
