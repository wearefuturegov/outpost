class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :url, :email
  belongs_to :organisation
end
