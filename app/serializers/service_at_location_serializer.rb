class ServiceAtLocationSerializer < ActiveModel::Serializer
  attribute :service_id, key: :id
  attribute :service_name, key: :name
  attribute :service_description, key: :description
  attribute :service_email, key: :email
  attribute :service_url, key: :url
  attribute :distance, key: :distance_away, if: :location_search?

  has_one :location
  belongs_to :organisation

  def location_search?
    object.try(:distance).present?
  end
end
