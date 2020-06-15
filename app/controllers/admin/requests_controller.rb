class Admin::RequestsController < Admin::BaseController
    def index
        @requests = Service.kept.where(approved: false).includes(:organisation, :service_taxonomies, :taxonomies)
    end

    def update
        @request = Service.find(params[:id])
        if @request.approve
            redirect_to request.referer, notice: "Changes have been approved."
            ServiceMailer.with(service: @request).notify_owners_email.deliver_later
        end
    end
end