class Admin::OfstedController < Admin::BaseController
    before_action :set_counts
    
    def index
        @query = params.permit(:query)

        @items = OfstedItem.page(params[:page])

        @items = @items.search(params[:query]) if params[:query].present?

        @items = @items.newest if params[:order] === "desc" && params[:order_by] === "registration_date"
        @items = @items.oldest if params[:order] === "asc" && params[:order_by] === "registration_date"
        @items = @items.newest_changed if params[:order] === "desc" && params[:order_by] === "last_change_date"
        @items = @items.oldest_changed if params[:order] === "asc" && params[:order_by] === "last_change_date"
    end

    def show
        @item = OfstedItem.find(params[:id])
    end

    def pending
        @pending_services = OfstedService.ofsted_pending
    end

    private

    def set_counts
        @pending_count = OfstedService.ofsted_pending.count
        @feed_count = OfstedItem.count
    end
end