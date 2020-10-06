class TaskListController < ApplicationController
    before_action :set_service

    def index
    end

    def edit
    end

    def update
        render :index
    end

    private

    def set_service
        @service = current_user.organisation.services.find(params[:service_id])
    end
end