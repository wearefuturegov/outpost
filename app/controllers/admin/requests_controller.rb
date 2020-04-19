class Admin::RequestsController < Admin::BaseController
    def index
        @requests = Service.kept.where(approved: false)
    end

    def update
        @request = Service.find(params[:id])
        @request.approve
        redirect_to admin_requests_path, notice: "Changes have been approved"
    end
end