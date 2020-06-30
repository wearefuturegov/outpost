include RegularScheduleHelper

class RegularScheduleSerializer < ActiveModel::Serializer
  attributes :weekday
  attributes :opens_at
  attributes :closes_at

  def weekday
    weekdays.find{ |d| d[:value] === object.weekday }[:label]
  end

end