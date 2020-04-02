class API::V1::ServicesController < ApplicationController
  def index
    @services = Service.includes(:organisation).all
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
end