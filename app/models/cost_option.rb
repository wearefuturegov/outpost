class CostOption < ApplicationRecord
  belongs_to :service

  validates_presence_of :amount
end
