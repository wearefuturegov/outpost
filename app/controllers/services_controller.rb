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
    end

    def service_params
        result_params = params.require(:service).permit(
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
            taxonomy_ids: [],
            send_need_ids: [],
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
                :type,
                :_destroy,
            ],
            regular_schedules_attributes: [
                :id,
                :opens_at,
                :closes_at,
                :weekday,
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

end