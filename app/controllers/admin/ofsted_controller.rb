class Admin::OfstedController < Admin::BaseController
    before_action :ofsted_admins_only
    before_action :set_counts
    
    def index
        @query = params.permit(:query)

        @items = OfstedItem.kept.page(params[:page]).order(setting_name: :ASC)

        @items = @items.search(params[:query]) if params[:query].present?
        @items = @items.newest if params[:order] === "desc" && params[:order_by] === "registration_date"
        @items = @items.oldest if params[:order] === "asc" && params[:order_by] === "registration_date"
        @items = @items.newest_changed if params[:order] === "desc" && params[:order_by] === "last_change_date"
        @items = @items.oldest_changed if params[:order] === "asc" && params[:order_by] === "last_change_date"
    end

    def show
        @item = OfstedItem.find(params[:id])
        @related_items = OfstedItem.where(rp_reference_number: @item.rp_reference_number).where.not(id: params[:id])
        @versions = @item.versions.order(created_at: :asc).reverse
        if @item.versions.length > 4
          @versions = @versions.first(3)
          @versions.push(@service.versions.last)
        end
    end

    def archive
      @query = params.permit(:query)

      @items = OfstedItem.discarded.page(params[:page]).order(setting_name: :ASC)
      
      @items = @items.search(params[:query]) if params[:query].present?
      @items = @items.newest if params[:order] === "desc" && params[:order_by] === "registration_date"
      @items = @items.oldest if params[:order] === "asc" && params[:order_by] === "registration_date"
      @items = @items.newest_changed if params[:order] === "desc" && params[:order_by] === "last_change_date"
      @items = @items.oldest_changed if params[:order] === "asc" && params[:order_by] === "last_change_date"
      render "index"
    end

    def versions
      @item = OfstedItem.find(params[:ofsted_id])
      @snapshots = @item.versions.reverse
      render :layout => "full-width"
    end

    def pending
      @requests = OfstedItem.where
        .not(status: nil)
        .order(status: :ASC)
        .order(updated_at: :ASC)
    end

    def dismiss
      @item = OfstedItem.find(params[:ofsted_id])
      @item.status = nil
      @item.save
      redirect_to pending_admin_ofsted_index_path
    end

    private

    def set_counts
        @feed_count = OfstedItem.count
        @archived_count = OfstedItem.discarded.count
    end

    def ofsted_admins_only
      unless current_user.admin_ofsted? 
        redirect_to admin_root_path, notice: "You don't have permission to see the Ofsted feed."
      end
    end
end