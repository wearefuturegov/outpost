class Admin::OfstedController < Admin::BaseController
    before_action :set_counts
    
    def index    
        @query = params.permit(:query)

        @items = OfstedItem.page(params[:page])
        @items = @items.search(params[:query]) if params[:query].present?
    end

    def pending
        @pending_services = ChildcareService.where(approved: false)
        byebug
    end

    private

    def set_counts
        @pending_count = ChildcareService.where(approved: false).count
        @feed_count = OfstedItem.count
    end
end