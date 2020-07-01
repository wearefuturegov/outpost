include RegularScheduleHelper

class RegularScheduleSerializer < ActiveModel::Serializer
  attributes :weekday
  attributes :opens_at
  attributes :closes_at

  def weekday
    weekdays.find{ |d| d[:value] === object.weekday }[:label]
  end

  def opens_at
    DateTime.strptime(object.opens_at, '%Y-%m-%d').to_time.utc if object.opens_at
  end

  def closes_at
    DateTime.strptime(object.closes_at, '%Y-%m-%d').to_time.utc if object.closes_at
  end

end