class API::V1::ServicesController < ApplicationController
  def index
    @services = Service.all
    render json: @services
  end
end