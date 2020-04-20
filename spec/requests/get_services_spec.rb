require 'rails_helper'

describe "get all services", type: :request do
  let!(:organisations) { FactoryBot.create_list(:organisation_with_services, 5) }

  before { get '/api/v1/services' }

  it 'returns all services' do
    expect(JSON.parse(response.body)["content"].size).to eq(20)
  end

  it 'returns status code 200' do
    expect(response).to have_http_status(:success)
  end

  it 'returns meta data for services' do
    @services = ServiceAtLocation.page(nil)
    expected = {
      totalElements: ServiceAtLocation.all.count,
      totalPages: @services.total_pages,
      number: @services.current_page,
      size: @services.limit_value
    }
    expect(JSON.parse(response.body)).to include(JSON.parse(expected.to_json))
  end

  it 'returns correct service data for services' do
    byebug
    service_at_location = ServiceAtLocation.first
    response_service = JSON.parse(response.body)["content"].first
    expect(response_service["id"]).to eq(service_at_location.service_id)
    expect(response_service["name"]).to eq(service_at_location.service_name)
    expect(response_service["description"]).to eq(service_at_location.service_description)
    expect(response_service["url"]).to eq(service_at_location.service_url)
    expect(response_service["email"]).to eq(service_at_location.service_email)
  end

  it 'returns correct organisation data for services' do
    service_at_location = ServiceAtLocation.first
    organisation = service_at_location.organisation
    response_organisation = JSON.parse(response.body)["content"].first["organisation"]
    expect(response_organisation["id"]).to eq(organisation.id)
    expect(response_organisation["name"]).to eq(organisation.name)
    expect(response_organisation["description"]).to eq(organisation.description)
    expect(response_organisation["url"]).to eq(organisation.url)
  end
end