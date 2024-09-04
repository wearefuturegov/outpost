class ServicesController < ApplicationController
    before_action :no_admins
    before_action :set_service, except: [:new, :create]

    def new
        @service = current_user.organisation.services.new
    end

    def create
        @service = current_user.organisation.services.new(service_params)
        @service.approved = false
        if @service.save
            session[:currently_creating] = @service.id
            # mark first item done
            session[:completed_sections] = ["name_and_description"]
            redirect_to service_path(@service)
        else
            render :new
        end
    end

    def show
        @currently_creating = session[:currently_creating] === @service.id
        @completion_count = session[:completed_sections].try(:length) || 0
    end

    def edit
        render "_edit_#{params[:section]}"
    end

    def confirmation
        session[:currently_creating] = nil
        session[:completed_sections] = []
    end

    def update
        if params[:section] && session[:completed_sections]
            session[:completed_sections] |= [params[:section]]
        end
        if params[:service]
            @service.approved = false
            # force paper trail version to be saved
            @service.updated_at = Time.now
            if @service.update(service_params)
                redirect_to service_path(@service)
            else
                render "_edit_#{params[:section]}"
            end
        else
            redirect_to service_path(@service)
        end
    end

    def destroy
        @service.approved = false
        @service.archive
        redirect_to organisations_path, notice: "That service will be removed as soon as we approve it."
    end

    private

    def set_service
        @service = current_user.organisation.services.find(params[:id] || params[:service_id])
        @custom_field_sections = CustomFieldSection.visible_to(current_user).where('custom_fields_count > 0')
    end


    def service_params
        preprocessed_params = preprocess_regular_schedules(params)
        result_params = preprocessed_params.require(:service).permit(
            :name,
            :description,
            :url,
            :email,
            :visible_from,
            :visible_to,
            :visible,
            :bccn_member,
            :current_vacancies,
            :pick_up_drop_off_service,
            :free,
            :needs_referral, 
            :referral_url,
            :min_age,
            :max_age,
            :temporarily_closed,

            :age_band_under_2,
            :age_band_2,
            :age_band_3_4,
            :age_band_5_7,
            :age_band_8_plus,
            :age_band_all,
            #taxonomy_ids: []
            send_need_ids: [],
            suitability_ids: [],
            local_offer_attributes: [
                :id,
                :description,
                :link,
                :_destroy,
                survey_answers: [
                    :question,
                    :answer
                ]
            ],
            cost_options_attributes: [
                :id,
                :option,
                :amount,
                :cost_type,
                :_destroy,
            ],
            regular_schedules_attributes: [
                :id,
                :service_at_location_id,
                :weekday,
                :opens_at,
                :closes_at,
                :dtstart,
                :interval,
                :freq,
                :byday,
                :bymonthday,
                :until,
                :count,
                :_destroy,
            ],
            contacts_attributes: [
                :id,
                :name,
                :title,
                :visible,
                :email,
                :phone,
                :_destroy,
            ],
            links_attributes: [
                :id,
                :label,
                :url,
                :_destroy
            ],
            locations_attributes: [
                :id,
                :name,
                :address_1,
                :city,
                :postal_code,
                :visible,
                :mask_exact_address,
                :preferred_for_post,
                :_destroy,
                accessibility_ids: []
            ],
            meta_attributes: [
            :id,
            :key,
            :value
            ]
        )
        # map fields_for submitted values, which are of the form 'id => { answer: text }' into an array of '[{ id: id, answer: text }]'
        if result_params['local_offer_attributes']&.[]('survey_answers')
            result_params['local_offer_attributes']['survey_answers'] =
                result_params['local_offer_attributes']['survey_answers'].to_h.map{|k,v| { id: k.to_i, answer: v['answer']}}
        end

        result_params
    end

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


