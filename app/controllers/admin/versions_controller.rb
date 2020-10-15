class Admin::VersionsController < Admin::BaseController
    def index
        @service = Service.find(params[:service_id])
        @versions = @service.versions.reverse
        render :layout => "full-width"
    end
end