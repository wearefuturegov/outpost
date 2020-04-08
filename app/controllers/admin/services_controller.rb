class Admin::ServicesController < Admin::BaseController
  before_action :set_service, only: [:show, :update]

  def index
    if params[:query].present?
      @services = Service.search(params[:query]).page(params[:page])
    else
      @services = Service.newest # default sort
      @services = Service.alphabetical if params[:order] === "asc" && params[:order_by] === "name"
      @services = Service.reverse_alphabetical if params[:order] === "desc" && params[:order_by] === "name"
      @services = Service.oldest if params[:order] === "asc" && params[:order_by] === "updated_at"
      @services = @services.page(params[:page])
    end
    respond_to do |format|
      format.html
      format.csv { send_data Service.all.to_csv }
    end
  end

  def show
    @watched = current_user.watches.where(service_id: @service.id).exists?
    
    @versions = @service.versions
    @versions = @versions.last(3).reverse.push(@versions.first) if @versions.length > 3 #summarise if many versions recorded
  end

  def update
    if @service.update(service_params)
      redirect_to admin_services_path
    else
      render "show"
    end
  end

  def watch
    current_user.watches.create(service_id: params[:id])
    current_user.save
    redirect_to admin_service_path
  end

  def unwatch
    current_user.watches.find_by(service_id: params[:id]).destroy
    redirect_to admin_service_path
  end
  
  def new
    @service = Service.new
  end

  def create
    @service = Service.create(service_params)
    if @service.save
      redirect_to admin_services_path
    else
      render "new"
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