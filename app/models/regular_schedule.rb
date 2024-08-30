class RegularSchedule < ApplicationRecord
  belongs_to :service
  belongs_to :service_at_location, optional: true

  validates_presence_of :weekday
  validates_presence_of :opens_at
  validates_presence_of :closes_at
  validate :validate_hours


  # frequency is a string that can be either 'WEEKLY' or 'MONTHLY'
  enum freq: { week: 'WEEKLY', month: 'MONTHLY' } 

  #  byday
  enum byday: { monday: 'MO', tuesday: 'TU', wednesday: 'WE', thursday: 'TH', friday: 'FR', saturday: 'SA', sunday: 'SU' }

  def validate_hours
    if opens_at.present? && closes_at.present? && opens_at > closes_at
      errors.add(:base, :impossible_hours)
    end
  end

end
