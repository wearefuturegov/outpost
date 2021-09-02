class Admin::RequestsController < Admin::BaseController
    def index
        @requests = Service
            .page(params[:page])
            .where(approved: nil)
            .includes(:organisation, :service_taxonomies, :taxonomies, :taggings, :meta, :contacts, :local_offer, :send_needs, :cost_options, :regular_schedules, locations: [:accessibilities])
            .with_last_approved_version
            .with_last_version
            .order(updated_at: :DESC)

          @requests = @requests.tagged_with(params[:directory], on: :directories) if params[:directory].present?

            @counts_all = {
                all: @requests.all.count,
                ofsted: @requests.ofsted_registered.count,
                pending: @requests.kept.count,
                archived: @requests.discarded.count
              }
              @counts = {}
              @counts[:all] = @counts_all
          
              if APP_CONFIG["directories"].present?
                APP_CONFIG["directories"].each do |directory|
                  service = @requests.tagged_with(directory, on: :directories)
                  @dir_counts = {
                    all: service.count,
                    ofsted: service.ofsted_registered.count,
                    pending: service.kept.count,
                    archived: service.discarded.count
                  }
                  @counts[directory["value"]] = @dir_counts
                end
              end
    end

    def update
        @request = Service.find(params[:id])
        if @request.approve
            redirect_to request.referer, notice: "Changes have been approved."
            ServiceMailer.with(service: @request).notify_owners_email.deliver_later
        end
    end
end