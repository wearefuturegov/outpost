class Admin::VersionsController < Admin::BaseController
    before_action :set_service
    def index
        @versions = @service.versions.reverse
    end

    def update
        @version = PaperTrail::Version.find(params[:id])
        @version.reify.save
        redirect_to admin_service_url(@service), notice: "Restored from previous version"
    end

    private

    def set_service
        @service = Service.find(params[:service_id])
    end
end