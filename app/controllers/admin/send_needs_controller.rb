class Admin::SendNeedsController < Admin::BaseController
    def index
        @send_needs = SendNeed.order(:name).page(params[:page])
    end

    def new
        @send_need = SendNeed.new
    end

    def create
        @send_need = SendNeed.create(send_need_params)
        if @send_need.save
          redirect_to admin_send_needs_path, notice: "SEND need has been created."
        else
          render "new"
        end
    end

    def create_defaults
        SendNeed.defaults.each do |default|
            SendNeed.find_or_create_by(name: default)
        end
        redirect_to admin_send_needs_path, notice: "Default options have been added."
    end


    private


    def send_need_params
        params.require(:send_need).permit(
          :name
        )
      end
end
