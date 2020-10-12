class Admin::VersionsController < Admin::BaseController
    def index
        @service = Service.find(params[:service_id])
        @snapshots = @service.versions.order(created_at: :desc)
        @live_object = @service.as_json
        render :layout => "full-width"
    end
end