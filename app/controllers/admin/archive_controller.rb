class Admin::ArchiveController < Admin::BaseController
    def index
        @services = Service.discarded
    end

    def update
        @service = Service.find(params[:id])
        @service.paper_trail_event = 'unarchive'
        @service.undiscard
        @service.paper_trail.save_with_version
        redirect_to admin_service_path(@service), notice: "Service moved out of the archive"
    end
end