class Contact < ApplicationRecord
  belongs_to :service

  has_one :phone
end