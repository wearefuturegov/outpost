class OrganisationSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :url
end
