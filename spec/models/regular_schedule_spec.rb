require 'rails_helper'

RSpec.describe RegularSchedule, type: :model do
  it { should validate_presence_of :weekday }
  it { should validate_presence_of :opens_at }
  it { should validate_presence_of :closes_at }


  it { should define_enum_for(:weekday).with_values(
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6,
    sunday: 7
  ) }




  # hours - cant have opens_at after closes_at
  describe '#validate_hours' do
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(opens_at:opens_at, closes_at: closes_at, weekday: 'monday', service: service) }

    context 'when opens_at is the same time as before closes_at' do
      let(:opens_at) { Time.zone.now }
      let(:closes_at) { Time.zone.now }

      it 'is valid' do
        expect(regular_schedule).to be_valid
      end
    end

    context 'when opens_at is before closes_at' do
      let(:opens_at) { Time.zone.now - 1.hour }
      let(:closes_at) { Time.zone.now }

      it 'is valid' do
        expect(regular_schedule).to be_valid
      end
    end

    context 'when opens_at is after closes_at' do
      let(:opens_at) { Time.zone.now + 1.hour }
      let(:closes_at) { Time.zone.now }

      it 'is invalid' do
        expect(regular_schedule).to_not be_valid
      end
    end
  end

  describe '#validate_byday_format' do
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(dtstart: DateTime.new(2023, 10, 4), freq: frequency, opens_at: Time.zone.now, closes_at: Time.zone.now, weekday: 'monday', service: service) }
  

    context 'when freq is week' do
      let(:frequency) { 'week' }
      
      it 'Accepts valid single days of the week' do
        regular_schedule.byday = 'MO'
        expect(regular_schedule).to be_valid
      end

      it 'Doesn\'t accept invalid single days of the week' do
        regular_schedule.byday = 'OK'
        expect(regular_schedule).to_not be_valid
      end

      it 'Accepts valid multiple days of the week' do
        regular_schedule.byday = 'MO,TU,WE,TH,FR,SA,SU'
        expect(regular_schedule).to be_valid
      end

      it 'Doesn\'t accept invalid multiple days of the week' do
        regular_schedule.byday = 'OK,TU,WE,TH,FR,SA,SU'
        expect(regular_schedule).to_not be_valid
      end

      it 'Doesn\'t accept repeated days of the week' do
        regular_schedule.byday = 'TU,TU,WE,TH,FR,SA,SU'
        expect(regular_schedule).to_not be_valid
      end

      it 'Doesn\'t accept invalid single days of the week' do
        regular_schedule.byday = '2TU'
        expect(regular_schedule).to_not be_valid
      end

      it 'Doesn\'t accept invalid multiple days of the week' do
        regular_schedule.byday = '1MO,-1TU'
        expect(regular_schedule).to_not be_valid
      end

    end

    context 'when freq is month' do
      let(:frequency) { 'month' }
      
      it 'Accepts valid single days of the week' do
        regular_schedule.byday = '1MO'
        expect(regular_schedule).to be_valid
      end

      it 'Accepts valid multiple days of the week' do
        regular_schedule.byday = '1MO,-1TU'
        expect(regular_schedule).to be_valid
      end

      it 'Doesn\'t accept 0 before a day of the week' do
        regular_schedule.byday = '0MO'
        expect(regular_schedule).to_not be_valid
      end

      it 'Doesn\'t accept 0 before a day of the week, multiple' do
        regular_schedule.byday = '0MO,1TU'
        expect(regular_schedule).to_not be_valid
      end

      it 'Doesn\'t accept a number > 5 before a day of the week' do
        regular_schedule.byday = '6MO'
        expect(regular_schedule).to_not be_valid
      end

      it 'Doesn\'t accept a number > 5 before a day of the week, multiple' do
        regular_schedule.byday = '6MO,1TU'
        expect(regular_schedule).to_not be_valid
      end
    end
    
  end


  # bymonthday must be between 1 and 31
  describe '#validate_bymonthday_range' do
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(dtstart: DateTime.new(2023, 10, 4), opens_at: Time.zone.now, closes_at: Time.zone.now, weekday: 'monday', service: service) }

    context 'when byday is not a valid day' do
      it 'is invalid' do
        regular_schedule.bymonthday = 50
        expect(regular_schedule).to_not be_valid
        expect(regular_schedule.errors[:bymonthday]).to include("Repeated monthly event on this date must be between 1 and 31")
      end
    end

    context 'when byday is a valid day' do
      it 'is valid' do
        regular_schedule.bymonthday = 4
        expect(regular_schedule).to be_valid
      end
    end
  end

  # interval must be >= 1
  describe '#validate_interval' do
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(freq: 'week', dtstart: DateTime.new(2023, 10, 4), opens_at: Time.zone.now, closes_at: Time.zone.now, weekday: 'monday', service: service) }

    # since we set it ourselves
    context 'when interval is empty' do
      it 'is valid' do
        expect(regular_schedule).to be_valid
      end
    end

    context 'when interval is 1' do
      it 'is valid' do
        regular_schedule.interval = 1
        expect(regular_schedule).to be_valid
      end
    end

    context 'when interval is < 1' do
      it 'is invalid' do
        regular_schedule.interval = 0
        expect(regular_schedule).to_not be_valid
        expect(regular_schedule.errors[:interval]).to include("Interval for repeated events must be greater than or equal to 1")
      end
    end
  end

  # bymonthday must be the same as the day of the month in dtstart
  describe '#validate_bymonthday_and_dtstart' do

    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(dtstart: DateTime.new(2023, 10, 4), opens_at: Time.zone.now, closes_at: Time.zone.now, weekday: 'monday', service: service) }

    context 'when bymonthday is the same as the day of the month in dtstart' do
      it 'is valid' do
        regular_schedule.bymonthday = 4
        expect(regular_schedule).to be_valid
      end
    end

    context 'when bymonthday is not the same as the day of the month in dtstart' do
      it 'is invalid' do
        regular_schedule.bymonthday = 5
        expect(regular_schedule).to_not be_valid
      end
    end

  end


  # validations for event times vs opening times
  # opening_time
  # weekday, opens_at, closes_at (also byday, bymonthday, until, count are never permitted)
  # event_time
  # dtstart, weekday, opens_at, closes_at, (also byday, bymonthday, until, count are permitted)

  describe '#validate_event_type' do

    let(:service) { FactoryBot.create(:service) }


    context 'when opening time' do
      let(:regular_schedule) { RegularSchedule.new(opens_at: Time.zone.now, closes_at: Time.zone.now, weekday: 'monday', service: service) }

      it 'should require weekday, opens_at, closes_at' do
        expect(regular_schedule).to be_valid
      end

      it 'should not allow byday' do
        regular_schedule.byday = 'MO'
        expect(regular_schedule).to_not be_valid
      end

      it 'should not allow bymonthday' do
        regular_schedule.bymonthday = 3
        expect(regular_schedule).to_not be_valid
      end

      it 'should not allow until' do
        regular_schedule.until = DateTime.new(2024, 10, 4)
        expect(regular_schedule).to_not be_valid
      end

      it 'should not allow count' do
        regular_schedule.count = 5
        expect(regular_schedule).to_not be_valid
      end

    end

    context 'when event time' do
      let(:regular_schedule) { RegularSchedule.new(dtstart: DateTime.new(2023, 10, 4), opens_at: Time.zone.now, closes_at: Time.zone.now, weekday: 'monday', service: service) }

      it 'should require dtstart, weekday, opens_at, closes_at' do
        expect(regular_schedule).to be_valid
      end

      it 'should allow byday' do
        regular_schedule.byday = 'MO'
        expect(regular_schedule).to be_valid
      end

      it 'should allow bymonthday' do
        regular_schedule.bymonthday = 4
        expect(regular_schedule).to be_valid
      end

      it 'should allow until' do
        regular_schedule.until = DateTime.new(2024, 10, 4)
        expect(regular_schedule).to be_valid
      end

      it 'should allow count' do
        regular_schedule.count = 5
        expect(regular_schedule).to be_valid
      end

    end


  end


  # validate_repeated_event
  describe '#validate_repeated_event' do
      let(:service) { FactoryBot.create(:service) }
      let(:regular_schedule) { RegularSchedule.new(dtstart: DateTime.new(2023, 10, 4), freq: frequency, opens_at: Time.zone.now, closes_at: Time.zone.now, weekday: 'monday', service: service) }

      context 'when freq is set' do
        let(:frequency) { 'week' }
        it 'should only allow count' do
          regular_schedule.count = 5
          expect(regular_schedule).to be_valid
        end

        it 'should only allow until' do
          regular_schedule.until = DateTime.new(2024, 10, 4)
          expect(regular_schedule).to be_valid
        end

        it 'should not allow count and until' do
          regular_schedule.count = 5
          regular_schedule.until = DateTime.new(2024, 10, 4)
          expect(regular_schedule).to_not be_valid
        end

        it 'should allow count and until to be emty' do
          expect(regular_schedule).to be_valid
        end
      end


      context 'when freq is weekly' do
        let(:frequency) { 'week' }
        it 'should not allow bymonthday' do
          regular_schedule.bymonthday = 5
          expect(regular_schedule).to_not be_valid
        end
        it 'should allow valid byday' do
          regular_schedule.byday = 'MO'
          expect(regular_schedule).to be_valid
        end
        it 'should not allow invalid byday' do
          regular_schedule.byday = '1MO'
          expect(regular_schedule).to_not be_valid
        end
      end

      context 'when freq is monthly' do
        let(:frequency) { 'month' }
        it 'should allow bymonthday' do
          regular_schedule.bymonthday = 4
          expect(regular_schedule).to be_valid
        end
        it 'should allow valid byday' do
          regular_schedule.byday = '1MO'
          expect(regular_schedule).to be_valid
        end
        it 'should not allow invalid byday' do
          regular_schedule.byday = 'MO'
          expect(regular_schedule).to_not be_valid
        end
        it 'should not allow bymonthday and byday' do
          regular_schedule.bymonthday = 5
          regular_schedule.byday = '1MO'
          expect(regular_schedule).to_not be_valid
        end
        it 'should set byday if none set' do
          expect(regular_schedule).to be_valid
        end
      end
  end


  # HELPERS

  describe "#get_month_byday_values" do
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(dtstart: DateTime.new(2023, 10, 4), freq: frequency, opens_at: Time.zone.now, closes_at: Time.zone.now, service: service) }


    context 'when frequency is week' do 
      let(:frequency) { 'week' }

      it 'should return nil if byday is blank' do
        expect(regular_schedule.get_month_byday_values).to be_nil
      end

      it 'should return array of days if byday is set' do
        regular_schedule.byday = 'MO,WE'
        expect(regular_schedule.get_month_byday_values).to eq([['MO'], ['WE']])
      end

    end


    context 'when frequency is week' do 
      let(:frequency) { 'month' }

      it 'should return nil if byday is blank' do
        expect(regular_schedule.get_month_byday_values).to be_nil
      end

      it 'should return array of days if byday is set' do
        regular_schedule.byday = '-1MO,2WE'
        expect(regular_schedule.get_month_byday_values).to eq([['-1','MO'], ['2','WE']])
      end

    end

  end


  describe '#description' do
    let(:opens_at) { Time.zone.now - 1.hour  }
    let(:closes_at) { Time.zone.now + 1.hour  }
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(dtstart: dtstart, weekday: 'wednesday', opens_at: opens_at, closes_at: closes_at, service: service) }


    context 'opening times' do
      let(:dtstart) { nil } 
      it 'should return description of the opening time' do
        expect(regular_schedule.description).to eq("Wednesday from #{opens_at.to_s(:time)} to #{closes_at.to_s(:time)}")
      end
    end


    context 'event times' do
      let(:dtstart) { DateTime.new(2023, 10, 4) } # Wednesday
      context 'single event time' do
        it 'should return description of the single event time' do
          expect(regular_schedule.description).to eq("#{dtstart.strftime('%A%e %B %Y')} from #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end
      end

      context 'weekly event time' do
        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 1
          expect(regular_schedule.description).to eq("Every week from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 2
          expect(regular_schedule.description).to eq("Every 2 weeks from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end


        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 1
          regular_schedule.byday = 'MO'
          expect(regular_schedule.description).to eq("Every week on Monday from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 2
          regular_schedule.byday = 'MO'
          expect(regular_schedule.description).to eq("Every 2 weeks on Monday from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 1
          regular_schedule.byday = 'MO,TU'
          expect(regular_schedule.description).to eq("Every week on Monday and Tuesday from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 2
          regular_schedule.byday = 'MO,TU'
          expect(regular_schedule.description).to eq("Every 2 weeks on Monday and Tuesday from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end


        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 1
          regular_schedule.byday = 'MO,TU,FR'
          expect(regular_schedule.description).to eq("Every week on Monday, Tuesday and Friday from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 2
          regular_schedule.byday = 'MO,TU,FR'
          expect(regular_schedule.description).to eq("Every 2 weeks on Monday, Tuesday and Friday from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end
      end

      context 'monthly event time' do
        it 'should return description of the monthly event time' do
          regular_schedule.freq = 'month'
          regular_schedule.interval = 1
          expect(regular_schedule.description).to eq("Every month from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the monthly event time' do
          regular_schedule.freq = 'month'
          regular_schedule.interval = 2
          expect(regular_schedule.description).to eq("Every 2 months from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end


        it 'should return description of the monthly event time' do
          regular_schedule.freq = 'month'
          regular_schedule.interval = 1
          regular_schedule.bymonthday = 4
          expect(regular_schedule.description).to eq("Every month on the 4th of the month from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the monthly event time' do
          regular_schedule.freq = 'month'
          regular_schedule.interval = 2
          regular_schedule.bymonthday = 4
          expect(regular_schedule.description).to eq("Every 2 months on the 4th of the month from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end


        it 'should return description of the monthly event time' do
          regular_schedule.freq = 'month'
          regular_schedule.interval = 1
          regular_schedule.byday = '1MO'
          expect(regular_schedule.description).to eq("Every month on the First Monday of the month from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the monthly event time' do
          regular_schedule.freq = 'month'
          regular_schedule.interval = 2
          regular_schedule.byday = '1MO'
          expect(regular_schedule.description).to eq("Every 2 months on the First Monday of the month from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the monthly event time' do
          regular_schedule.freq = 'month'
          regular_schedule.interval = 1
          regular_schedule.byday = '1MO,-1FR'
          expect(regular_schedule.description).to eq("Every month on the First Monday and Last Friday of the month from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the monthly event time' do
          regular_schedule.freq = 'month'
          regular_schedule.interval = 2
          regular_schedule.byday = '1MO,-1FR'
          expect(regular_schedule.description).to eq("Every 2 months on the First Monday and Last Friday of the month from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the monthly event time' do
          regular_schedule.freq = 'month'
          regular_schedule.interval = 1
          regular_schedule.byday = '1MO,-1FR,3FR'
          expect(regular_schedule.description).to eq("Every month on the First Monday, Last Friday and Third Friday of the month from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end

        it 'should return description of the monthly event time' do
          regular_schedule.freq = 'month'
          regular_schedule.interval = 2
          regular_schedule.byday = '1MO,-1FR,3FR'
          expect(regular_schedule.description).to eq("Every 2 months on the First Monday, Last Friday and Third Friday of the month from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")}")
        end
        
        
      end


      # @TODO can we have count + interval?
      context 'event time ends' do
        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 2
          regular_schedule.byday = 'MO,TU,FR'
          regular_schedule.until = DateTime.new(2024, 10, 4)
          expect(regular_schedule.description).to eq("Every 2 weeks on Monday, Tuesday and Friday from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")} until #{DateTime.new(2024, 10, 4).strftime("%d/%m/%Y")}")
        end

        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 2
          regular_schedule.byday = 'MO,TU,FR'
          regular_schedule.count = 5
          expect(regular_schedule.description).to eq("Every 2 weeks on Monday, Tuesday and Friday from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")} for 5 occurrences")
        end      
        
        it 'should return description of the weekly event time' do
          regular_schedule.freq = 'week'
          regular_schedule.interval = 2
          regular_schedule.byday = 'MO,TU,FR'
          regular_schedule.count = 1
          expect(regular_schedule.description).to eq("Every 2 weeks on Monday, Tuesday and Friday from #{dtstart.strftime("%d/%m/%Y")} at #{opens_at.strftime("%I:%M%P")} to #{closes_at.strftime("%I:%M%P")} once")
        end
      end

    end




  end




  

  # CALLBACKS


  # Weekday is required in open referral but doesn't always make sense for users to input it
  describe '#set_weekday_from_dtstart' do
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(dtstart: dtstart, opens_at: Time.zone.now, closes_at: Time.zone.now, service: service) }


    context 'when dtstart is present and weekday is blank' do
      let(:dtstart) { DateTime.new(2023, 10, 4) } # Wednesday
      it 'sets the weekday based on dtstart' do        
        regular_schedule.valid? # Triggers the before_validation callback
        expect(regular_schedule.weekday).to eq('wednesday')
      end
    end

    context 'when dtstart is present and weekday is already set' do
      let(:dtstart) { DateTime.new(2023, 10, 4) } # Example date: Wednesday

      it 'should change the weekday' do
        regular_schedule.weekday = 'monday'
        regular_schedule.valid? # Triggers the before_validation callback
        expect(regular_schedule.weekday).to eq('wednesday')
      end
    end

    context 'when dtstart is not present' do
      let(:dtstart) { nil }

      it 'does not set the weekday' do
        regular_schedule.valid? # Triggers the before_validation callback
        expect(regular_schedule.weekday).to be_nil
      end
    end
  end

  # set byday and bymonthday if they're not set
  describe '#set_byday_bymonthday_from_dtstart' do
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(freq: frequency, interval: 2, dtstart: DateTime.new(2023, 10, 4), opens_at: Time.zone.now, closes_at: Time.zone.now, service: service) }

    # when weekly and byday is not set
    context "when weekly frequency is set but byday is not" do
      let(:frequency) { 'week' }
      it "should set byday based on dtstart" do
        regular_schedule.valid?
        expect(regular_schedule.byday).to eq('WE')
        expect(regular_schedule.bymonthday).to eq(nil)
      end
    end

    # when monthly and bymonthday is not set
    context "when monthly frequency is set but bymonthday is not" do
      let(:frequency) { 'month' }
      it "should set byday based on dtstart" do
        regular_schedule.valid?
        expect(regular_schedule.bymonthday).to eq(4)
        expect(regular_schedule.byday).to eq(nil)
      end
    end
  end

 # interval is required 
  describe '#set_interval' do
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(dtstart: DateTime.new(2023, 10, 4), opens_at: Time.zone.now, closes_at: Time.zone.now, service: service) }

    context 'when freq is not set' do
      it 'it should not set interval' do
        regular_schedule.valid?
        expect(regular_schedule.interval).to be_nil
      end
    end

    context 'when freq is set' do

      it 'it should set interval' do
        regular_schedule.freq = 'week'
        regular_schedule.valid?
        expect(regular_schedule.interval).to eq(1)
      end

      it 'it should set interval to the submitted value' do
        regular_schedule.freq = 'week'
        regular_schedule.interval = 2
        regular_schedule.valid?
        expect(regular_schedule.interval).to eq(2)
      end
    end
  
  end

  # TYPES of schedules

  describe '#save opening times' do 
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(opens_at: Time.zone.now, closes_at: Time.zone.now, service: service) }

    # OPENING TIMES
    it 'Lets us save opening times' do
      regular_schedule.weekday = 'monday'

      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save

      expect(regular_schedule.weekday).to eq('monday')
    end
  end

  describe '#save event time' do 
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(opens_at: Time.zone.now, closes_at: Time.zone.now, service: service) }

    # SINGLE EVENT TIME
    it 'Lets us save a single event time' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday

      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save

      expect(regular_schedule.weekday).to eq('wednesday')
    end
  end



  describe '#save event time - weekly' do
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(freq: 'week', interval: 2, opens_at: Time.zone.now, closes_at: Time.zone.now, service: service) }

    # WEEKLY

    # event repeats every 2 weeks starting from 4/10/2023
    it 'Lets us save an event that repeats every 2 weeks with no additional information set' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday

      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save

      expect(regular_schedule.dtstart).to eq(DateTime.new(2023, 10, 4))
      expect(regular_schedule.interval).to eq(2)
      expect(regular_schedule.weekday).to eq('wednesday')
    end

    # event repeats every 2 weeks ON a MONDAY AND WEDNESDAY starting from 4/10/2023
    it 'Lets us save an event that repeats every 2 weeks on a monday and wednesday' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday
      regular_schedule.byday = 'MO,WE'

      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save

      expect(regular_schedule.dtstart).to eq(DateTime.new(2023, 10, 4))
      expect(regular_schedule.byday).to eq('MO,WE')
      expect(regular_schedule.weekday).to eq('wednesday')
    end

    # event repeats every 2 weeks until 4/10/2024
    it 'Lets us save an event that repeates every 2 weeks until a specific date' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday
      regular_schedule.until = DateTime.new(2024, 10, 4)

      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save

      expect(regular_schedule.dtstart).to eq(DateTime.new(2023, 10, 4))
      expect(regular_schedule.interval).to eq(2)
      expect(regular_schedule.byday).to eq('WE')
      expect(regular_schedule.weekday).to eq('wednesday')
      expect(regular_schedule.until).to eq(DateTime.new(2024, 10, 4))
    end


    # event repeats every 2 weeks for 5 times
    it 'Lets us save an event that repeates every 2 weeks until 5 events have occured' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday
      regular_schedule.interval = 2
      regular_schedule.count = 5

      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save

      expect(regular_schedule.dtstart).to eq(DateTime.new(2023, 10, 4))
      expect(regular_schedule.interval).to eq(2)
      expect(regular_schedule.byday).to eq('WE')
      expect(regular_schedule.weekday).to eq('wednesday')
      expect(regular_schedule.count).to eq(5)
    end


  end



  describe '#save event time - monthly' do
    let(:service) { FactoryBot.create(:service) }
    let(:regular_schedule) { RegularSchedule.new(freq: 'month', interval: 2, opens_at: Time.zone.now, closes_at: Time.zone.now, service: service) }

  
    # MONTHS

    # event repeats every 2 months starting from 4/10/2023
    it 'Lets us save an event that repeats every 2 months with no additional information' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday
    
  
      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save


      expect(regular_schedule.dtstart).to eq(DateTime.new(2023, 10, 4))
      expect(regular_schedule.interval).to eq(2)
      expect(regular_schedule.byday).to eq(nil)
      expect(regular_schedule.bymonthday).to eq(4)
      expect(regular_schedule.weekday).to eq('wednesday')
    end

    # event repeats every 2 months on the 1st day of the month starting from 4/10/2023
    # @TODO 
    # If an event is set to repeat every month on the 31st, and a month doesn’t have a 31st (like February, April, June, September, or November), the event will typically adjust as follows:
    # February: The event usually falls on the 28th or 29th (if it's a leap year).
    # April, June, September, November: The event typically falls on the 30th.
    it 'Lets us save an event that repeats every 2 months on day number 2 of the month' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday
      regular_schedule.bymonthday = 4
    
  
      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save


      expect(regular_schedule.dtstart).to eq(DateTime.new(2023, 10, 4))
      expect(regular_schedule.interval).to eq(2)
      expect(regular_schedule.byday).to eq(nil)
      expect(regular_schedule.bymonthday).to eq(4)
      expect(regular_schedule.weekday).to eq('wednesday')
    end

    # event repeats every 2 months on the 1st day of the month until 4/10/2024
    it 'Lets us save an event that repeats every 2 months until a specific date' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday
      regular_schedule.until = DateTime.new(2024, 10, 4)
  
      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save


      expect(regular_schedule.dtstart).to eq(DateTime.new(2023, 10, 4))
      expect(regular_schedule.interval).to eq(2)
      expect(regular_schedule.byday).to eq(nil)
      expect(regular_schedule.bymonthday).to eq(4)
      expect(regular_schedule.weekday).to eq('wednesday')
      expect(regular_schedule.until).to eq(DateTime.new(2024, 10, 4))
    end
    
    # event repeats every 2 months on the 1st day of the month until 5 times
    it 'Lets us save an event that repeats every 2 months until 5 events have occured' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday
      regular_schedule.count = 5
  
      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save


      expect(regular_schedule.dtstart).to eq(DateTime.new(2023, 10, 4))
      expect(regular_schedule.interval).to eq(2)
      expect(regular_schedule.byday).to eq(nil)
      expect(regular_schedule.bymonthday).to eq(4)
      expect(regular_schedule.weekday).to eq('wednesday')
      expect(regular_schedule.count).to eq(5)
    end

    # event repeats every 2 months on the last sunday of the month starting from 4/10/2023
    it 'Lets us save an event that repeats every 2 months on the first sunday and second to last tuesday of the month' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday
      regular_schedule.byday = '-1SU'
    
  
      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save


      expect(regular_schedule.dtstart).to eq(DateTime.new(2023, 10, 4))
      expect(regular_schedule.interval).to eq(2)
      expect(regular_schedule.byday).to eq('-1SU')
      expect(regular_schedule.bymonthday).to eq(nil)
      expect(regular_schedule.weekday).to eq('wednesday')
    end
    
    # event repeats every 2 months on the first sunday and second to last tuesday of the month starting from 4/10/2023
    it 'Lets us save an event that repeats every 2 months on the first sunday and second to last tuesday of the month' do
      regular_schedule.dtstart = DateTime.new(2023, 10, 4) # Wednesday
      regular_schedule.byday = '1SU,-2TU'
    
  
      regular_schedule.valid? # Triggers the before_validation callback
      expect(regular_schedule).to be_valid
      regular_schedule.save


      expect(regular_schedule.dtstart).to eq(DateTime.new(2023, 10, 4))
      expect(regular_schedule.interval).to eq(2)
      expect(regular_schedule.byday).to eq('1SU,-2TU')
      expect(regular_schedule.bymonthday).to eq(nil)
      expect(regular_schedule.weekday).to eq('wednesday')
    end


  end
end
