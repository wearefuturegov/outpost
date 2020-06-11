class Admin::SnapshotsController < Admin::BaseController
    before_action :set_service
    before_action :set_snapshot, only: [:show, :update]

    def index
        @snapshots = @service.snapshots.order(created_at: :desc).includes([:user])
        @live_object = @service.as_json
        render :layout => "full-width"
    end

    def show
        @service = @snapshot
        render "admin/services/show"
    end

    def update
        @snapshot.restore
        redirect_to admin_service_snapshots_path(@service)
    end

    private

    def set_service
        @service = Service.find(params[:service_id])
    end

    def set_snapshot
        @snapshot = @service.snapshots.find(params[:id])
    end
end