class API::V1::ServicesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if params[:coverage].present?
      @services = ServiceAtLocation.kept.near(params[:coverage]).page(params[:page]).includes(:organisation)
    else
      @services = ServiceAtLocation.kept.order(:service_name).page(params[:page]).includes(:organisation)
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
    @service = Service.kept.find(params[:id])
    render json: @service
  end

  def serialized_services
    ActiveModel::Serializer::CollectionSerializer.new(@services)
  end

end