require 'rails_helper'

describe 'Accessibilities endpoint', type: :request do

  let(:api_endpoint) { '/api/v1/accessibilities' }

  context 'with accessibilities in the DB' do
    let!(:accessibility) { FactoryBot.create(:accessibility) }

    it 'returns accessibilities' do
      get api_endpoint
      response_body = JSON.parse(response.body)

      accessibilities_response = [{
        'id' => accessibility.id,
        'label' => accessibility.name,
        'slug' => accessibility.slug
      }]

      expect(response_body).to match_array(accessibilities_response)
    end
  end

  context 'with no accessibilities in the DB' do
    it 'returns an empty array' do
      get api_endpoint
      response_body = JSON.parse(response.body)
      expect(response_body).to match_array([])
    end
  end
end
