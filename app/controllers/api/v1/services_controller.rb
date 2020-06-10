class API::V1::ServicesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    service_at_location_scope = ServiceAtLocation.kept
    unless taxonomy_params.nil?
      service_at_location_scope = service_at_location_scope.in_taxonomies(taxonomy_params)
    end
    if params[:lat].present? && params[:lng].present?
      service_at_location_scope = service_at_location_scope.near([params[:lat], params[:lng]], 20)
    elsif params[:coverage].present?
      service_at_location_scope = service_at_location_scope.near(params[:coverage])
    end

    if params[:keywords].present?
      service_at_location_scope = service_at_location_scope.search(params[:keywords])
    end

    service_at_location_scope = service_at_location_scope.page(params[:page]).includes(:organisation)

    @services = service_at_location_scope

    render json: {
      "totalElements": @services.total_count,
      "totalPages": @services.total_pages,
      "number": @services.current_page,
      "size": @services.limit_value,
      "content": serialized_services
    }, include: "organisation,location,contacts,contacts.phones,taxonomies"
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