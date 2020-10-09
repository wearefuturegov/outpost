class Admin::OfstedController < Admin::BaseController
    before_action :ofsted_admins_only
    before_action :set_counts
    
    def index
      @filterrific = initialize_filterrific(
        OfstedItem,
        params[:filterrific],
        select_options: {
          sorted_by: OfstedItem.options_for_sorted_by
        },
        persistence_id: false,
        default_filter_params: {},
        available_filters: [
          :sorted_by, 
          :search
        ],
        sanitize_params: true,
      ) || return
  
      @items = @filterrific.find.page(params[:page])

      # shortcut nav
      if params[:archived] === "true"
        @items = @items.discarded
      else
        @items = @items.kept
      end
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