class ServicesController < ApplicationController
    before_action :set_service, only: [:show, :update]

    def new
        @service = current_user.organisation.services.new
    end

    def create
        @service = current_user.organisation.services.build(service_params)
        @service.approved = false
        if @service.save
            redirect_to organisations_path, notice: "Your service has been submitted for review. You'll be emailed when it's approved."
        else
            render "new"
        end
    end

    def show
    end

    def update
        @service.approved = false
        if @service.update(service_params)
            redirect_to organisations_path, notice: "Your changes have been submitted for review. You'll be emailed when they're approved."
        else
            render "show"
        end
    end

    private

    def set_service
        @service = current_user.organisation.services.find(params[:id])
    end

    def service_params
        params.require(:service).permit(
            :name,
            :description
        )
    end

end