class ServicesController < ApplicationController
    before_action :no_admins
    before_action :set_service, except: [:new, :create]

    def new
        @service = current_user.organisation.services.new
    end

    def create
        @service = current_user.organisation.services.new(service_params)
        if @service.save
            redirect_to service_task_list_index_path(@service)
        else
            render :new
        end
    end

    def show
    end

    def update
        @service.approved = false
        if params[:service].nil? || @service.update(service_params)
            if params[:stage]
                redirect_to edit_service_path(@service, :stage => helpers.next_stage(params[:stage]))
            else
                redirect_to service_path(@service), notice: "That service will be updated as soon as we approve it."
            end
        else
            if params[:stage]
                @stage = params[:stage]
                render "edit"
                return
            end
            render "show"
        end
    end

    def destroy
        @service.approved = false
        @service.archive
        redirect_to organisations_path, notice: "That service will be removed as soon as we approve it."
    end

    private

    def set_service
        @service = current_user.organisation.services.find(params[:id])
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
              # :latitude,
              # :longitude,
              # :google_place_id,
              :_destroy,
              accessibility_ids: []
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