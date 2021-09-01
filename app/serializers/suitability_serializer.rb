class SuitabilitySerializer < ActiveModel::Serializer
  attributes :id
  attributes :name
  attributes :slug

  def slug
    object.name.parameterize
  end
end