class Contact < ApplicationRecord
  belongs_to :service
  has_many :phones

  accepts_nested_attributes_for :phone
end