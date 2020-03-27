require 'rails_helper'

describe "get a single service", type: :request do
  let!(:organisations) { FactoryBot.create_list(:organisation_with_services, 5) }

  before { get "/api/v1/services/#{Service.first.id}" }

  it 'returns the correct service' do
    expect(JSON.parse(response.body)["service"]["id"]).to eq(Service.first.id)
  end

  it 'returns status code 200' do
    expect(response).to have_http_status(:success)
  end
end