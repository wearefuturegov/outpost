class Admin::OfstedController < Admin::BaseController
    before_action :set_counts
    
    def index    
        @query = params.permit(:query)

        @items = OfstedItem.page(params[:page])
        @items = @items.search(params[:query]) if params[:query].present?
    end

    def pending
    end

    private

    def set_counts
        # @pending_count = 
        @feed_count = OfstedItem.count
    end
end