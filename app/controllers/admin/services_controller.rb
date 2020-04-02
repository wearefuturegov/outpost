class Admin::ServicesController < Admin::BaseController
  before_action :set_service, only: [:show, :update]

  def index
    @services = Service.order(updated_at: :desc).page(params[:page])
  end

  def show
  end

  def update
    if @service.update(service_params)
      redirect_to admin_services_path
    else
      render "show"
    end
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(
      :name,
      :organisation_id,
      :description,
      :url,
      :email
    )
  end

end