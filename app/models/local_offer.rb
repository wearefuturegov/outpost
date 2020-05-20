class LocalOffer < ApplicationRecord
  belongs_to :service

  validates :description, presence: true
end
