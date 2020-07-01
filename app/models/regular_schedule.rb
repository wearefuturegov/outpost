class RegularSchedule < ApplicationRecord
  belongs_to :service

  validates_presence_of :weekday
  validates_presence_of :opens_at
  validates_presence_of :closes_at
  validate :validate_hours

  def validate_hours
    if opens_at.present? && closes_at.present? && opens_at > closes_at
      errors.add(:base, :impossible_hours)
    end
  end
end
