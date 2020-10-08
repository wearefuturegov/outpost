class Admin::LocationsController < Admin::BaseController
    before_action :set_location, only: [:show, :update]

    def index
        @filterrific = initialize_filterrific(
          Location,
          params[:filterrific],
          select_options: {
            sorted_by: Location.options_for_sorted_by,
            services: Location.options_for_services
          },
          persistence_id: "shared_key",
          default_filter_params: {},
          available_filters: [
            :sorted_by, 
            :search,
            :services
          ],
          sanitize_params: true,
        ) || return
    
        @locations = @filterrific.find.page(params[:page])

        respond_to do |format|
            format.html
            format.json { render :json => @locations }
        end
      end


    def show
    end

    def update
        if @location.update(location_params)
            redirect_to admin_location_path(@location), notice: "Location has been updated."
        else
            render "show"
        end
    end

    private

    def set_location
        @location = Location.find(params[:id])
    end

    def location_params
        params.require(:location).permit(
            :name,
            :address_1,
            :city,
            :state_province,
            :postal_code,
            :country,
            :visible,
            :mask_exact_address,
            accessibility_ids: []
        )
    end
end