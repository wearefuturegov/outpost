class ServicesController < ApplicationController

    def new
        @service = current_user.organisation.services.new
    end

    def create
        @service = current_user.organisation.services.build(service_params)
        if @service.valid?
            current_user.request_for_create(@service, reason: "something").save
            redirect_to organisations_path, notice: "Your service has been submitted for review. You'll be emailed when it's approved."
        else
            render "new"
        end
    end

    def show
    end

    def update
    end

    private

    def set_service
    end

    def service_params
        params.require(:service).permit(
            :name,
            :description
        )
    end

end