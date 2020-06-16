class ServicesController < ApplicationController
    before_action :no_admins
    before_action :set_service, only: [:edit, :show, :update, :destroy]

    def new
        @service = current_user.organisation.services.new
    end

    def create
        @service = current_user.organisation.services.build(service_params)
        @service.approved = false
        if @service.save
            redirect_to edit_service_path(@service, :stage => 'access')
        else
            render "new"
        end
    end

    def edit
        @stage = params[:stage] || 'basic-information'
    end

    def show

    end

    def update
        @service.approved = false
        if @service.update(service_params)
            stages = helpers.service_creation_steps
            next_step = stages[stages.index(params[:stage]) + 1]
            redirect_to edit_service_path(@service, :stage => next_step)
        else
            render "show"
        end
    end

    def destroy
        @service.archive
        redirect_to organisations_path, notice: "That service has been removed and will no longer be visible."
    end

    private

    def set_service
        @service = current_user.organisation.services.find(params[:id])
    end

    def service_params
        params.permit(:service).permit(
          :name,
          :description,
          :url,
          :email,
          :visible_from,
          :visible_to,
          taxonomy_ids: [],
          location_ids: [],
          contacts_attributes: [
            :id,
            :name,
            :title,
            :_destroy,
            phones_attributes: [
              :id,
              :number
            ]
          ],
          locations_attributes: [
            :id,
            :name,
            :address_1,
            :city,
            :postal_code,
            # :latitude,
            # :longitude,
            # :google_place_id,
            :_destroy,
            accessibility_ids: []
          ]
        )
      end

end