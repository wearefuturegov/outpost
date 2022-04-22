require 'rails_helper'

describe 'GET suitabilities endpoint', type: :request do
  let(:api_endpoint) { '/api/v1/suitabilities' }

  context 'with suitabilities in the DB' do
    let!(:suitability) { FactoryBot.create(:suitability) }

    it 'returns suitabilities' do
      suitabilities_response = [{
        'id' => suitability.id,
        'label' => suitability.name,
        'slug' => suitability.slug
      }]

      get api_endpoint
      response_body = JSON.parse(response.body)
      expect(response_body).to match_array(suitabilities_response)
    end
  end

  context 'with no suitabilities in the DB' do
    it 'returns an empty array' do
      get api_endpoint
      response_body = JSON.parse(response.body)
      expect(response_body).to match_array([])
    end
  end
end
