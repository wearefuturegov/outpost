include RegularScheduleHelper

class RegularScheduleSerializer < ActiveModel::Serializer
  attributes :id, :weekday, :opens_at, :closes_at, :dtstart, :freq, :interval, :byday, :bymonthday, :until, :count, :description

  def weekday
    object.weekday.humanize
  end

  def opens_at
    object.opens_at.to_s(:time)   
  end

  def closes_at
    object.closes_at.to_s(:time)   
  end

  def dtstart
    object.dtstart.strftime('%Y-%m-%d').to_time.utc if object.dtstart
  end

  def dtstart
    object.until.strftime('%Y-%m-%d').to_time.utc if object.until
  end

  def description
    object.description
  end


end
