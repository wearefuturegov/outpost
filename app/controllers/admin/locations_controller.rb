class Admin::LocationsController < Admin::BaseController
    before_action :set_location, only: [:show, :update]

    def index
        @locations = Location.page(params[:page])
        @locations = @locations.search(params[:query]) if params[:query].present?
        @locations = @locations.only_with_services if params[:filter_services] === "with"
        @locations = @locations.only_without_services if params[:filter_services] === "without"

        respond_to do |format|
            format.html
            format.json { render :json => @locations }
        end
    end

    def show
    end

    def new
        @location = Location.new
    end

    def create
        @location = Location.new(location_params)
        if @location.save
            redirect_to admin_location_path(@location), notice: "Location has been created"
        else
            render "new"
        end
    end

    def update
        if @location.update(location_params)
            redirect_to admin_location_path(@location), notice: "Location has been updated"
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
            accessibility_ids: []
        )
    end
end