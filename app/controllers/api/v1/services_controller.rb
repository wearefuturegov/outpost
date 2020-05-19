class API::V1::ServicesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    service_type = convert_service_type(params[:service_type])

    service_at_location_scope = ServiceAtLocation.kept
    service_at_location_scope = service_at_location_scope.joins(service: :taxonomies).where(taxonomies: { name: service_type } ) if service_type.present?
    if (params[:lat].present? && params[:lng].present?)
      service_at_location_scope = service_at_location_scope.near([params[:lat], params[:lng]], 20).page(params[:page]).includes(:organisation)
    elsif params[:coverage].present?
      service_at_location_scope = service_at_location_scope.near(params[:coverage]).page(params[:page]).includes(:organisation)
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
    render json: @service, include: "organisation,locations,contacts,contacts.phones,taxonomies"
  end

  def serialized_services
    ActiveModel::Serializer::CollectionSerializer.new(@services)
  end

  def convert_service_type service_type
    case service_type
    when 'services'
      'Things to do'
    when 'childcare'
      'Childcare and Early Years'
    when '  '
      'Education and learning'
    when 'advice_support'
      'Advice and support'
    end
  end

end