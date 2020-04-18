class OrganisationsController < ApplicationController
    # before_action :require_not_onboarded, only: [:new, :create]

    def start
    end

    def index
        @organisation = current_user.organisation
    end

    def new
        @organisation = Organisation.new
        @organisation.services.build
    end

    def create
        @organisation = Organisation.new(organisation_params)
        if @organisation.save
            current_user.organisation = @organisation
            current_user.save
            redirect_to organisations_path
        else
            render "new"
        end
    end

    private

    def organisation_params
        params.require(:organisation).permit(
            :name,
            :services_attributes => [
                :name,
                :description
            ]
        )
    end

    def require_not_onboarded
        redirect_to organisations_path if current_user.organisation
    end
end