class Admin::SuitabilitiesController < Admin::BaseController
    def index
        @suitabilities = Suitability.order(:name).page(params[:page])
    end

    def new
        @suitability = Suitability.new
    end

    def create
        @suitability = Suitability.create(suitability_params)
        if @suitability.save
          redirect_to admin_suitabilities_path, notice: "Suitability has been created."
        else
          render "new"
        end
    end

    def create_defaults
        Suitability.defaults.each do |default|
          Suitability.find_or_create_by(name: default)
        end
        redirect_to admin_suitabilities_path, notice: "Default options have been added."
    end


    private


    def suitability_params
        params.require(:suitability).permit(
          :name
        )
      end
end
