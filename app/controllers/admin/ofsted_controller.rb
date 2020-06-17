class Admin::OfstedController < Admin::BaseController
    before_action :ofsted_admins_only
    before_action :set_counts
    before_action :set_item, only: [:show, :dismiss]
    
    def index
        @query = params.permit(:query)

        @items = OfstedItem.page(params[:page]).order(setting_name: :ASC)

        @items = @items.search(params[:query]) if params[:query].present?

        @items = @items.newest if params[:order] === "desc" && params[:order_by] === "registration_date"
        @items = @items.oldest if params[:order] === "asc" && params[:order_by] === "registration_date"
        @items = @items.newest_changed if params[:order] === "desc" && params[:order_by] === "last_change_date"
        @items = @items.oldest_changed if params[:order] === "asc" && params[:order_by] === "last_change_date"
    end

    def show
        @versions = @item.versions.order(created_at: :desc)
        if @item.versions.length > 4
          @versions = @versions.first(3)
          @versions.push(@service.versions.last)
        end
    end

    def pending
      @new = OfstedItem.where(status: "new")
      @changed = OfstedItem.where(status: "changed")
      @deleted = OfstedItem.where(status: "deleted")
    end

    def dismiss
      @item.status = nil
      @item.save
    end

    private

    def set_counts
        @feed_count = OfstedItem.count
    end

    def ofsted_admins_only
      unless current_user.admin_ofsted? 
        redirect_to admin_root_path, notice: "You don't have permission to see the Ofsted feed."
      end
    end

    def set_item
      @item = OfstedItem.find(params[:id])
    end
end