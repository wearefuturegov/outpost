class OrganisationsController < ApplicationController

    def start
    end

    def index
        @organisation = current_user.organisation
    end

    def new
        @service = Service.new
        @service.build_organisation
    end

    def create
        @service = Service.create(service_params)
        if @service.save
            current_user.organisation = @service.organisation
            current_user.save
            redirect_to services_path
        else
            render "new"
        end
    end

    private

    def service_params
        params.require(:service).permit(
          :name,
          :description,
          :organisation_attributes => [
              :name
          ]
        )
    end
end