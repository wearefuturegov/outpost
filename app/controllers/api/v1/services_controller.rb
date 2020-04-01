class API::V1::ServicesController < ApplicationController
  def index
    @services = Service.all

    render json: {
      "totalElements": @services.count,
      "content": @services
    }
  end

  def show
    @service = Service.find(params[:id])
    render json: @service
  end
end