require 'rails_helper'

describe 'GET SEND needs endpoint', type: :request do
  let(:api_endpoint) { '/api/v1/send_needs' }

  context 'with SEND needs in the DB' do
    let!(:send_need) { FactoryBot.create(:send_need) }

    it 'returns SEND needs' do
      send_need_response = [{
        'id' => send_need.id,
        'label' => send_need.name,
        'slug' => send_need.slug
      }]

      get api_endpoint
      response_body = JSON.parse(response.body)
      expect(response_body).to match_array(send_need_response)
    end
  end

  context 'with no SEND needs in the DB' do
    it 'returns an empty array' do
      get api_endpoint
      response_body = JSON.parse(response.body)
      expect(response_body).to match_array([])
    end
  end
end
