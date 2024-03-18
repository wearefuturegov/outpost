class Admin::AccessibilitiesController < Admin::BaseController
    def index
        @accessibilities = Accessibility.order(:name).page(params[:page])
    end

    def new
        @accessibility = Accessibility.new
    end

    def create
        @accessibility = Accessibility.create(accessibility_params)
        if @accessibility.save
          redirect_to admin_accessibilities_path, notice: "Accessibility has been created."
        else
          render "new"
        end
    end

    def create_defaults
        Accessibility.defaults.each do |default|
          Accessibility.find_or_create_by(name: default)
        end
        redirect_to admin_accessibilities_path, notice: "Default options have been added."
    end


    private


    def accessibility_params
        params.require(:accessibility).permit(
          :name
        )
      end
end
