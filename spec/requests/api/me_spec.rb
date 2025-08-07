require 'rails_helper'

describe "API::V1::Me", type: :request do
  let!(:organisation) { FactoryBot.create :organisation }
  let!(:service) { FactoryBot.create :service, name: "Test Service", organisation: organisation }
  let(:user) { FactoryBot.create :user, :services_admin, organisation: organisation }

  
  let!(:oauth_app) { Doorkeeper::Application.create!(name: "Test", redirect_uri: "https://localhost:3000/auth/outpost/callback", scopes: "public") }
  let!(:token) do
    Doorkeeper::AccessToken.create!(
      application_id: oauth_app.id,
      resource_owner_id: user.id,
      scopes: "public"
    ).token
  end

  it "returns the current user's info" do
    get "/api/v1/me", headers: { "Authorization" => "Bearer #{token}" }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["id"]).to eq(user.id)
    expect(response.parsed_body["organisation"]["id"]).to eq(organisation.id)
    expect(response.parsed_body["organisation"]["services"].first["name"]).to eq("Test Service")
    expect(response.parsed_body["organisation"]["services"].count).to eq(1)
  end
end