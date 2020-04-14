class API::V1::ServicesController < ApplicationController
  def index
    if params[:coverage].present?
      @services = ServiceAtLocationSearchItem.near([0.51806796e2, -0.770305e0]).page(params[:page]).includes(:organisation)
      # render json: {
      #   "totalElements": @locations.total_count,
      #   "content": serialized_services
      #}
    else
      @services = ServiceAtLocationSearchItem.page(params[:page]).includes(:organisation)
    end

    render json: {
      "totalElements": @services.total_count,
      "totalPages": @services.total_pages,
      "number": @services.current_page,
      "size": @services.limit_value,
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