module ServicePreprocessing
  extend ActiveSupport::Concern

  private

  # we do a lot of form processing this method is used to clean up the params hash before saving
  def preprocess_regular_schedules(params)

    if params['service']['regular_schedules_attributes']
        params['service']['regular_schedules_attributes'].each do |key, schedule|
            if schedule['time_type'] == 'event_time'

                # if dtstart is present, use event_opens_at as opens_at and event_closes_at as closes_at
                if schedule['dtstart'].present?
                    schedule['opens_at'] = schedule['event_opens_at'] if schedule['event_opens_at'].present?
                    schedule['closes_at'] = schedule['event_closes_at'] if schedule['event_closes_at'].present?
                end

                # if its a repeated event, make sure the correct repeated event fields are present and formatted right
                if schedule['repeats']
                    # puts "Repeats #{schedule['repeats']}, #{schedule['freq']}"
                    if schedule['freq'] == 'week'
                        # uses byday only, joins byday array into a string
                        schedule['byday'] = schedule['byday'].to_unsafe_h.values.reject(&:blank?).join(',') if schedule['byday'].present?
                        %w[bymonthday byday_month].each do |key|
                            schedule[key] = nil
                        end
                    elsif schedule['freq'] == 'month'
                        # uses bymonthday, byday, byday_month and weekofmonth
                        # form validation takes care of both being set
                        schedule['byday'] = nil
                        # set byday to the correct format
                        if schedule['byday_month'].present?
                            schedule['byday'] = schedule['byday_month'].map { |entry| "#{entry['occurrence']}#{entry['byday']}" }.join(',')
                        end

                    end
                end

            elsif schedule['time_type'] == 'opening_time'
                # if its an opening time we dont want dtstart, until or count coming through
                %w[dtstart until count repeats].each do |key|
                    schedule[key] = nil
                end

            end


            # if its not a repeated event make sure the repeated event fields are empty
            if !schedule['repeats']
                %w[interval freq byday bymonthday byday_month until count].each do |key|
                    schedule[key] = nil
                end
            end 

            # remove unpermitted fields
            %w[time_type event_opens_at event_closes_at repeats byday_month].each do |key|
                schedule.delete(key)
            end
        end
    end

    params
end




end