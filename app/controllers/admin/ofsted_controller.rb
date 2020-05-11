class Admin::OfstedController < Admin::BaseController
    before_action :set_counts
    
    def index
        @pending_services = ChildcareService.page(params[:page])
    end

    def pending
        @pending_services = ChildcareService.where(approved: false)
        # byebug
    end

    def feed
        @query = params.permit(:query)

        @items = OfstedItem.page(params[:page])
        @items = @items.search(params[:query]) if params[:query].present?
    end

    private

    def set_counts
        @childcare_count = ChildcareService.count
        @pending_count = ChildcareService.where(approved: false).count
        @feed_count = OfstedItem.count
    end
end