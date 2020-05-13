class ContactSerializer < ActiveModel::Serializer
  attributes :id, :name, :title

  has_many :phones
end
