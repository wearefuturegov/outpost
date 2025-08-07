require 'rails_helper'

RSpec.describe "API::V1::Services", type: :request do
  let!(:services) { FactoryBot.create_list(:service, 5) }
  let!(:oauth_app) { Doorkeeper::Application.create!(name: "Test", redirect_uri: "https://localhost:3000/auth/outpost/callback", scopes: "admin") }
  let!(:token) do
    Doorkeeper::AccessToken.create!(
      application_id: oauth_app.id,
      scopes: "admin"
    ).token
  end

  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "GET /api/v1/services" do
    it "returns services for authorized request (mini)" do
      get "/api/v1/services?format=mini", headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["content"].length).to eq(5)
    end

    it "returns bad request for missing format" do
      get "/api/v1/services", headers: headers
      expect(response).to have_http_status(:bad_request)
    end

    it "returns bad request for too many ids" do
      ids = (1..21).to_a.join(",")
      get "/api/v1/services?format=mini&ids=#{ids}", headers: headers
      expect(response).to have_http_status(:bad_request)
    end

    it "returns only requested ids" do
      ids = services.first(2).map(&:id).join(",")
      get "/api/v1/services?format=mini&ids=#{ids}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["content"].length).to eq(2)
    end
  end

  describe "GET /api/v1/services/:id" do
    it "returns a single service (mini)" do
      service = services.first
      get "/api/v1/services/#{service.id}?format=mini", headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["id"]).to eq(service.id)
      expect(response.parsed_body["name"]).to eq(service.name)
    end

    it "returns bad request for missing/invalid format" do
      service = services.first
      get "/api/v1/services/#{service.id}", headers: headers
      expect(response).to have_http_status(:bad_request)
    end
  end
end