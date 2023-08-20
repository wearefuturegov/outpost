include RegularScheduleHelper

class RegularScheduleSerializer < ActiveModel::Serializer
  attributes :id, :weekday, :opens_at, :closes_at

  def weekday
    weekdays.find{ |d| d[:value] === object.weekday }[:label]
  end

  def opens_at
    object.opens_at.to_fs(:time)
  end

  def closes_at
    object.closes_at.to_fs(:time)
  end

end
