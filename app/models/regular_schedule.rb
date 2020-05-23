class RegularSchedule < ApplicationRecord
  belongs_to :service

  validates_presence_of :weekday
  validates_presence_of :opens_at
  validates_presence_of :closes_at
end
