class Service < ApplicationRecord
  belongs_to :organisation

  validates_presence_of :name
end