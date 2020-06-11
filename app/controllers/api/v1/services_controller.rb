class API::V1::ServicesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    result = ApprovedServices.all.map { |s| JSON.parse(s['object']) }
    result = Kaminari.paginate_array(result).page(params[:page])
    render json: result
  end

  def show
    @service = Service.kept.find(params[:id])
    service_json = ServiceSerializer.new(@service).to_json(root: false)
    render json: service_json, include: "organisation,locations,contacts,contacts.phones,taxonomies"
  end

  def serialized_services
    ActiveModel::Serializer::CollectionSerializer.new(@services)
  end

  private

  def taxonomy_params
    service_type_query = params[:service_type] || params[:taxonomies]
    return nil unless service_type_query
    service_type_query.split(',').map {|s|convert_service_type(s)}
  end

  def convert_service_type(service_type)
    case service_type
    when 'services'
      'Things to do'
    when 'childcare'
      'Childcare and Early Years'
    when 'schools'
      'Education and learning'
    when 'advice_support'
      'Advice and support'
    else
      service_type
    end
  end
end