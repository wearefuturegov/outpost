class Admin::SnapshotsController < Admin::BaseController
    def index
        @service = Service.find(params[:service_id])
        @snapshots = @service.snapshots.order(created_at: :desc).includes([:user])
        @live_object = @service.as_json
        render :layout => "full-width"
    end
end