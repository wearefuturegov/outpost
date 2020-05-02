class Admin::RequestsController < Admin::BaseController
    def index
        @requests = Service.kept.where(approved: false)
    end

    def update
        @request = Service.find(params[:id])
        @request.approve
        byebug
        redirect_to request.referer, notice: "Changes have been approved"
    end
end