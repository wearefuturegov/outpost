require 'rails_helper'

describe "get all services", type: :request do

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
end