class ServiceAtLocationSerializer < ActiveModel::Serializer
  attribute :service_id, key: :id
  attribute :service_name, key: :name
  attribute :service_description, key: :description
  attribute :service_email, key: :email
  attribute :service_url, key: :url

  belongs_to :organisation
end
