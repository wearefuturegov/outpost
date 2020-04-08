class API::V1::ServicesController < ApplicationController
  def index
    if params[:coverage].present?
      @locations = Location.near(params[:coverage]).includes(:services).page(params[:page])
      @services = services_from_locations
    else
      @services = Service.page(params[:page]).includes(:organisation).all
    end

    render json: {
      "totalElements": @services.count,
      "content": serialized_services
    }
  end

  def show
    @service = Service.find(params[:id])
    render json: @service
  end

  def serialized_services
    ActiveModel::Serializer::CollectionSerializer.new(@services)
  end

  def services_from_locations
    location_ids = @locations.map(&:id)

    @service_at_locations = ServiceAtLocation.where(location: location_ids)
    @service_at_locations_ordered = @service_at_locations.sort_by{ |service_at_location| location_ids.index service_at_location.location_id }

    @service_at_locations_ordered_service_ids = @service_at_locations_ordered.map(&:service_id)

    service_ids = @service_at_locations.map(&:service_id)
    @services = Service.where(id: service_ids).includes(:organisation)

    @services_ordered = @services.sort_by{ |service| @service_at_locations_ordered_service_ids.index service.id}

    @services_ordered
  end

end