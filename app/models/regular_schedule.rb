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
      'first' => '1',
      'second' => '2',
      'third' => '3',
      'fourth' => '4',
      'fifth' => '5',
      'last' => '-1',
    }  
  end


  # callbacks

  before_validation :set_weekday_from_dtstart
  before_validation :set_byday_bymonthday_from_dtstart
  before_validation :set_interval


  # helpers

  # get monthday and byday_month
  def get_month_byday_values
    return nil if byday.blank?
    byday_values = byday.split(',').map do |value|
      if value.length > 2
        [value[0..-3], value[-2..]]
      else
        [value]
      end
    end
    byday_values
  end


  # returns human readable description of the availability of the service.
  # Should match up with the iCAL field. E.g. 'The 2nd Monday of every month from 8:00pm till 12:00pm'
  def description
    day = ''
    ends = ''  
    # repeating event
    if dtstart.present?
      if freq.present?
        if self.until.present?
          ends = " until #{self.until.strftime("%d/%m/%Y")}"
        elsif count.present?
          ends = count > 1 ? " for #{count} occurrences" : " once"
        end

        if freq == 'week'
          week = interval == 1 ? 'week' : "#{interval} weeks"
          if byday.present?
            days = byday.split(',').map do |day|
              RegularSchedule.byday.key(day).humanize
            end
            day = " on #{days.to_sentence(last_word_connector: ' and ')}"
          end

          "Every #{week}#{day} from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}#{ends}"
        
        elsif freq == 'month'

          month = interval == 1 ? 'month' : "#{interval} months"
          if bymonthday.present?
            day = " on the #{bymonthday.to_i.ordinalize} of the month"
          end
          if byday.present?
            days = self.get_month_byday_values.map do |value|
              if value.length > 1
                "#{RegularSchedule.weekofmonth.key(value[0]).humanize} #{RegularSchedule.byday.key(value[1]).humanize}"
              else
                "#{RegularSchedule.weekofmonth.key(value[0]).humanize}"
              end
            end
            day = " on the #{days.to_sentence(last_word_connector: ' and ')} of the month"
          end
          "Every #{month}#{day} from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}#{ends}"
        end
      else
        "#{dtstart.strftime('%A')} from #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}"
      end
    else
      # opening time
      "#{weekday.humanize} from #{opens_at.to_s(:time)} to #{closes_at.to_s(:time)}"
    end

  end


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
          errors.add(:byday, "Repeated weekly events cannot have duplicate days")
        end
        days.each do |day|
          unless valid_days.include?(day)
            errors.add(:byday, "Repeated weekly event values must be one of #{valid_days.join(', ')}")
          end
        end
      elsif freq == 'month'
        unless byday.match?(/^((-?[1-5]#{valid_days.join('|-?[1-5]')})(,(-?[1-5]#{valid_days.join('|-?[1-5]')}))*)$/)
          errors.add(:byday, "Repeated monthly events byday must be in the format (-)[1-5]#{valid_days.join(',')}")
        end
      end
    end
  end

  # interval must be greater than or equal to 1
  def validate_interval
    if interval.present? && interval < 1
      errors.add(:interval, "Interval for repeated events must be greater than or equal to 1")
    end
  end


  # bymonthday must be between 1 and 31
  def validate_bymonthday_range
    if bymonthday.present? && (bymonthday < 1 || bymonthday > 31)
      errors.add(:bymonthday, "Repeated monthly event on this date must be between 1 and 31")
    end
  end

  # bymonthday must be the same as the day of the month in dtstart
  def validate_bymonthday_and_dtstart
    if bymonthday.present? && dtstart.present? && bymonthday.to_i != dtstart.strftime('%-d').to_i
      errors.add(:bymonthday, "Repeated monthly event on this date must be the same as the date of the first event")
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
        errors.add(:base, "Repeated weekly events require a date, weekday, opening and closing time")
      end
    else
      # Opening time: weekday, opens_at, closes_at are required
      if weekday.blank? || opens_at.blank? || closes_at.blank?
        errors.add(:base, "Opening times require a weekday, opening and closing time")
      end
      # byday, bymonthday, until, count must be empty
      if byday.present?
        errors.add(:base, "Opening times do not have byday values")
      end
      if bymonthday.present?
        errors.add(:base, "Opening times should not have bymonthday values")
      end
      if self.until.present?
        errors.add(:base, "Opening times should not have an until date")
      end
      if count.present?
        errors.add(:base, "Opening times should not have a count value")
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
          errors.add(:base, "Weekly schedules cannot have a bymonthday value")
        end
      elsif freq == 'month'
        # if freq is monthly
        # only byday or bymonthday can be set
        if self.byday.present? && bymonthday.present?
          errors.add(:base, "Monthly events can only repeat on the same date each month or specific days each month, not both")
        end
      end

      # Only until or count can be set, but not both
      if self.until.present? && count.present?
        errors.add(:until, "Until date cannot be set if count number is set")
        errors.add(:count, "Count number cannot be set if until date is set")
      end

    end

  end

  # callbacks

  # Weekday is required in open referral but doesn't always make sense for users to input it
  def set_weekday_from_dtstart
    if dtstart.present? 
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
      if !byday.present?
        self[:bymonthday] = dtstart.strftime('%-d')
      end
    end
  end


end
