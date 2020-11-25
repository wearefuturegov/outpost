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

  def opens_at
    if self[:opens_at].present?
      "#{self[:opens_at].hour}:#{self[:opens_at].min}0"
    end
  end

  def closes_at
    if self[:closes_at].present?
      "#{self[:closes_at].hour}:#{self[:closes_at].min}0"
    end
  end

end
