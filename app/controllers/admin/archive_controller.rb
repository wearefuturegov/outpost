class Admin::ArchiveController < Admin::BaseController
    def index
        @services = Service.discarded.page(params[:page]).includes(:taxonomies, :organisation)
    end

    def update
        @service = Service.find(params[:id])
        @service.restore
        redirect_to admin_service_path(@service), notice: "Service has been restored."
    end
end