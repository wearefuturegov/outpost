class Admin::ArchiveController < Admin::BaseController
    def update
        @service = Service.find(params[:id])
        @service.restore
        redirect_to request.referer, notice: "Service has been restored."
    end
end