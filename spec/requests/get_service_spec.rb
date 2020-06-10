require 'rails_helper'

describe "get a single service", type: :request do

  before { get "/api/v1/services/#{Service.first.id}" }

  it 'returns the correct service' do
    expect(JSON.parse(response.body)["id"]).to eq(Service.first.id)
  end

  it 'returns status code 200' do
    expect(response).to have_http_status(:success)
  end
end