class Admin::OfstedController < Admin::BaseController
    before_action :ofsted_admins_only
    before_action :set_counts
    
    def index
      @filterrific = initialize_filterrific(
        OfstedItem,
        params[:filterrific],
        select_options: {
          sorted_by: OfstedItem.options_for_sorted_by,
          with_status: OfstedItem.options_for_with_status,
          with_provision: OfstedItem.options_for_with_provision
        },
        persistence_id: false,
        default_filter_params: {},
        available_filters: [
          :sorted_by, 
          :with_status,
          :with_provision,
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

        @related_items = OfstedItem.where(rp_reference_number: @item.rp_reference_number).where.not(id: params[:id]) if @item.rp_reference_number.present?

        # If on a registered person provider item
        @registered_person_provider = OfstedItem.where(reference_number: @item.rp_reference_number).first
        @related_items ||= OfstedItem.where(rp_reference_number: @item.reference_number)

        if @item.versions.length > 4
          @versions = @item.versions.reverse.first(3)
          @versions.push(@item.versions.reverse.last)
        else
          @versions = @item.versions.reverse
        end
    end

    def versions
      @item = OfstedItem.find(params[:ofsted_id])
      @versions = @item.versions.reverse
      render :layout => "full-width"
    end

    def pending
      @requests = OfstedItem.where
        .not(status: nil)
        .order(updated_at: :desc)
        .page(params[:page])
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