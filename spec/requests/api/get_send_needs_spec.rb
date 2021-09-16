require 'rails_helper'

describe 'GET SEND needs endpoint', type: :request do
  let!(:send_need) { FactoryBot.create(:send_need) }

  it 'returns SEND needs' do
    get "/api/v1/send_needs"
    response_body = JSON.parse(response.body)
    expect(response_body).to match_array([{ 'id' => send_need.id, 'label' => send_need.name, 'slug' => send_need.slug }])
  end

end
