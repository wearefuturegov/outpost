class Admin::RequestsController < Admin::BaseController
    def index
        # byebug
        @requests = Service
            .where(approved: nil)
            .includes(:organisation, :service_taxonomies, :taxonomies)
            .order(updated_at: :DESC)
    end

    def update
        @request = Service.find(params[:id])
        if @request.approve
            redirect_to request.referer, notice: "Changes have been approved."
            ServiceMailer.with(service: @request).notify_owners_email.deliver_later
        end
    end
end