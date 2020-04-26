class Admin::SnapshotsController < ApplicationController
    before_action :set_service

    def index
        @snapshots = @service.snapshots.reverse
    end

    def update
        @snapshot = @service.snapshots.find(params[:id])
        @snapshot.restore
        redirect_to admin_service_snapshots_path(@service)
    end

    private

    def set_service
        @service = Service.find(params[:service_id])
    end
end