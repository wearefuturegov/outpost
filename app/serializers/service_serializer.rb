class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :url, :email

  has_many :locations
  belongs_to :organisation
  has_many :taxonomies
end
