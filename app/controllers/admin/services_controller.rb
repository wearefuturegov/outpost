class Admin::ServicesController < Admin::BaseController
  before_action :set_service, only: [:show, :update, :destroy]

  def index
    @services = Service.kept.page(params[:page]).includes(:taxonomies, :notes, organisation: [:users, :services])

    @services = @services.alphabetical if params[:order] === "asc" && params[:order_by] === "name"
    @services = @services.reverse_alphabetical if params[:order] === "desc" && params[:order_by] === "name"
    @services = @services.newest if params[:order] === "desc" && params[:order_by] === "updated_at"
    @services = @services.oldest if params[:order] === "asc" && params[:order_by] === "updated_at"

    @services = @services.in_taxonomy(params[:filter_taxonomy]) if params[:filter_taxonomy].present?
    @services = @services.scheduled if params[:filter_status].present? && params[:filter_status] === "scheduled"
    @services = @services.hidden if params[:filter_status].present? && params[:filter_status] === "hidden"

    @services = @services.search(params[:query]).page(params[:page]) if params[:query].present?
    @services = @services.order(updated_at: :DESC) # default sort
  end

  def show
    @watched = current_user.watches.where(service_id: @service.id).exists?
    @snapshots = @service.snapshots.order(created_at: :desc)
    if @service.snapshots.length > 4
      @snapshots = @snapshots.first(3)
      @snapshots.push(@service.snapshots.last)
    end
  end

  def update
    if @service.update(service_params)
      redirect_to admin_service_url(@service), notice: "Service has been updated."
    else
      render "show"
    end
  end

  def new
    @service = Service.new
  end

  def create
    @service = Service.create(service_params)
    if @service.save
      redirect_to admin_service_url(@service), notice: "Service has been created."
    else
      render "new"
    end
  end

  def destroy
    @service.archive
    redirect_to admin_service_url(@service)
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
      :email,
      :visible_from,
      :visible_to,
      taxonomy_ids: [],
      location_ids: [],
      send_need_ids: [],
      locations_attributes: [
        :id,
        :name,
        :address_1,
        :city,
        :postal_code,
        :latitude,
        :longitude,
        :_destroy,
        accessibility_ids: []
      ]
    )
  end

end