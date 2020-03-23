require 'rails_helper'

describe "get all services", type: :request do
  let!(:organisations) { FactoryBot.create_list(:organisation_with_services, 5) }
  #let!(:services) {FactoryBot.create_list(:service, 20, organisation: organisations.first)}

  before { get '/api/v1/services' }

  it 'returns all services' do
    expect(JSON.parse(response.body).size).to eq(25)
  end

  it 'returns status code 200' do
    expect(response).to have_http_status(:success)
  end
end