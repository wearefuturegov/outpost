class RegularSchedule < ApplicationRecord
  # weekday
  enum weekday: { monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7 }

  # frequency is a string that can be either 'WEEKLY' or 'MONTHLY'
  enum freq: { week: 'WEEKLY', month: 'MONTHLY' } 


  belongs_to :service
  belongs_to :service_at_location, optional: true

  validates_presence_of :weekday
  validates_presence_of :opens_at
  validates_presence_of :closes_at

  validate :validate_hours
  validate :validate_byday_format
  validate :validate_bymonthday_range
  validate :validate_event_type
  validate :validate_repeated_event
  validate :validate_bymonthday_and_dtstart
  validate :validate_interval
  
  #  byday
  def self.byday
    {
      'monday' => 'MO', 
      'tuesday' => 'TU', 
      'wednesday' => 'WE', 
      'thursday' => 'TH', 
      'friday' => 'FR', 
      'saturday' => 'SA', 
      'sunday' => 'SU'
    }  
  end

  # weekofmonth
  # only allowing specific values for weekofmonth to make things easier
  def self.weekofmonth
    {
      first: "1",
      second: "2",
      third: "3",
      fourth: "4",
      fifth: "5",
      last: "-1"
    }  
  end


  # callbacks

  before_validation :set_weekday_from_dtstart
  before_validation :set_byday_bymonthday_from_dtstart
  before_validation :set_interval

  private

  

  # validations


  # cant have opens_at after closes_at
  def validate_hours
    if opens_at.present? && closes_at.present? && opens_at > closes_at
      errors.add(:base, :impossible_hours)
    end
  end


  # byday
  # and must be SU,MO,TU,WE,TH,FR,SA or SU
  # byday must be in the format (-)[1-5]SU,(-)[1-5]MO,(-)[1-5]TU,(-)[1-5]WE,(-)[1-5]TH,(-)[1-5]FR,(-)[1-5]SA
  # validate byday format
  # if week
  # `MO`, `MO,TU` is valid
  # `MO,MO` is invalid
  # if month
  # `[-1,1,2,3,4,5][MO,TU,WE,TH,FR,SA,SU]` is valid
  # `MO,TU` is invalid
  def validate_byday_format
    if byday.present?
      valid_days = RegularSchedule.byday.values
      if freq == 'week'
        days = byday.split(',')
        if days.uniq.length != days.length
          errors.add(:base, "byday values must be unique")
        end
        days.each do |day|
          unless valid_days.include?(day)
            errors.add(:base, "byday must be one of #{valid_days.join(', ')}")
          end
        end
      elsif freq == 'month'
        unless byday.match?(/^((-?[1-5]#{valid_days.join('|-?[1-5]')})(,(-?[1-5]#{valid_days.join('|-?[1-5]')}))*)$/)
          errors.add(:base, "byday must be in the format (-)[1-5]#{valid_days.join(',')}")
        end
      end
    end
  end

  # interval must be greater than or equal to 1
  def validate_interval
    if interval.present? && interval < 1
      errors.add(:base, "Interval must be greater than or equal to 1")
    end
  end


  # bymonthday must be between 1 and 31
  def validate_bymonthday_range
    if bymonthday.present? && (bymonthday < 1 || bymonthday > 31)
      errors.add(:base, "By month day must be between 1 and 31")
    end
  end

  # bymonthday must be the same as the day of the month in dtstart
  def validate_bymonthday_and_dtstart
    if bymonthday.present? && dtstart.present? && bymonthday.to_i != dtstart.strftime('%-d').to_i
      errors.add(:base, "By month day must be the same as the day of the month in dtstart")
    end
  end




  # validations for event times vs opening times
  # opening_time
  # weekday, opens_at, closes_at (also byday, bymonthday, until, count are never permitted)
  # event_time
  # dtstart, weekday, opens_at, closes_at, (also byday, bymonthday, until, count are permitted)
  def validate_event_type

    if dtstart.present?
      # Event time: dtstart, weekday, opens_at, closes_at are required
      if weekday.blank? || opens_at.blank? || closes_at.blank?
        errors.add(:base, "dtstart, weekday, opens_at, and closes_at are required for event times")
      end
    else
      # Opening time: weekday, opens_at, closes_at are required
      if weekday.blank? || opens_at.blank? || closes_at.blank?
        errors.add(:base, "weekday, opens_at, and closes_at are required for opening times")
      end
      # byday, bymonthday, until, count must be empty
      if byday.present?
        errors.add(:base, "byday should be empty for opening times")
      end
      if bymonthday.present?
        errors.add(:base, "bymonthday should be empty for opening times")
      end
      if self.until.present?
        errors.add(:base, "until should be empty for opening times")
      end
      if count.present?
        errors.add(:base, "count should be empty for opening times")
      end
    end

  end 

  # validations for repeated events
  def validate_repeated_event

    # freq and interval tells us its a repeatable event
    # to make life easier we set interval to 1 if its not set
    if freq.present? && interval.present?
      if freq == 'week'
        # if freq is weekly
        # only byday can be set, bymonthday is not allowed at all
        if bymonthday.present?
          errors.add(:base, "bymonthday is not allowed for weekly schedules")
        end
      elsif freq == 'month'
        # if freq is monthly
        # only byday or bymonthday can be set
        if self.byday.present? && bymonthday.present?
          errors.add(:base, "Only byday or bymonthday can be set, not both")
        end
      end

      # Only until or count can be set, but not both
      if self.until.present? && count.present?
        errors.add(:base, "Only until or count can be set, not both")
      end

    end

  end

  # callbacks

  # Weekday is required in open referral but doesn't always make sense for users to input it
  def set_weekday_from_dtstart
    if dtstart.present? && weekday.blank?
      day_name = dtstart.strftime('%A').downcase
      day_value = RegularSchedule.weekdays[day_name].to_i
      self[:weekday] = day_name
    end
  end

  # set interval if its not set
  def set_interval
    if freq.present? && interval.blank?
      self[:interval] = 1 
    end
  end


  # set byday and bymonthday if they're not set
  def set_byday_bymonthday_from_dtstart
    # if weekly - byday is required but the days might not be selected by the user
    if freq == 'week'  && dtstart.present?
      if byday.blank?
        day_name = dtstart.strftime('%A').downcase
        day_value = RegularSchedule.byday[day_name]
        self[:byday] = day_value
      end
    # if monthly - bymonthday is required but the days might not be selected by the user
    elsif freq == 'month'  && dtstart.present?
      if !self.byday.present? && bymonthday.blank?
        self[:bymonthday] = dtstart.strftime('%-d')
      end
    end
  end

end
