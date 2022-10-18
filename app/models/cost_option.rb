# Represents the fees for a service
class CostOption < ApplicationRecord
  belongs_to :service

  validates_presence_of :amount

  include ActionView::Helpers::NumberHelper

  def amount
    number_with_precision(self[:amount], precision: 2)
  end
end
