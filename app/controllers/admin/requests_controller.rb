class Admin::RequestsController < Admin::BaseController
    def index
        @requests = Service
            .page(params[:page])
            .where(approved: nil)
            .includes(:organisation, :service_taxonomies, :taxonomies, :taggings, :meta, :contacts, :local_offer, :send_needs, :cost_options, :regular_schedules, locations: [:accessibilities])
            .with_last_approved_version
            .with_last_version
            .order(updated_at: :DESC)

          @requests = @requests.in_directory(params[:directory]) if params[:directory].present?

    end

    def update
        @request = Service.find(params[:id])
        if @request.approve
            redirect_to request.referer, notice: "Changes have been approved."
            ServiceMailer.with(service: @request).notify_owners_email.deliver_later
        end
    end
end