class ServiceAtLocationSerializer < ActiveModel::Serializer
  attribute :service_id, key: :id
  attribute :service_name, key: :name
  attribute :service_description, key: :description

  belongs_to :organisation
end
