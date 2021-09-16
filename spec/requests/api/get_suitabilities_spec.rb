require 'rails_helper'

describe 'GET suitabilities endpoint', type: :request do
  let!(:suitability) { FactoryBot.create(:suitability) }

  it 'returns suitabilities' do
    get "/api/v1/suitabilities"
    response_body = JSON.parse(response.body)
    expect(response_body).to match_array([{ 'id' => suitability.id, 'label' => suitability.name, 'slug' => suitability.slug }])
  end

end
