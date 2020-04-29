class Contact < ApplicationRecord
  belongs_to :service
  has_one :phone

  accepts_nested_attributes_for :phone
end