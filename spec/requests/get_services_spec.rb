require 'rails_helper'

describe "get all services endpoint", type: :request do

  describe 'unfiltered', type: :request do

    before do
      @organisation = FactoryBot.create(:organisation)
      @services = FactoryBot.create_list(:service, 3, organisation: @organisation)
      get '/api/v1/services'
    end

    it 'returns all services' do
      expect(JSON.parse(response.body)["content"].size).to eq(3)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(:success)
    end

    it 'returns meta data for services' do
      @services = ServiceAtLocation.page(nil)
      expected = {
          totalElements: ServiceAtLocation.all.count,
          totalPages: @services.total_pages,
          number: @services.current_page,
          size: @services.limit_value
      }
      expect(JSON.parse(response.body)).to include(JSON.parse(expected.to_json))
    end
  end

  describe 'Service queries', type: :request do

    before do
      @organisation = FactoryBot.create(:organisation)
      @services = FactoryBot.create_list(:service, 3, organisation: @organisation)

      root_taxonomy = Taxonomy.create(name: 'Categories')
      taxonomy_a = Taxonomy.create(name: 'A', parent_id: root_taxonomy.id)
      taxonomy_b = Taxonomy.create(name: 'B', parent_id: root_taxonomy.id)

      @services[0].taxonomies << taxonomy_a
      @services[1].taxonomies << taxonomy_b

      @services[2].taxonomies << taxonomy_a
      @services[2].taxonomies << taxonomy_b
    end

    RSpec.shared_examples "a taxonomy filtered endpoint" do |taxonomy_name|
      it 'filters the services at location based on taxonomy' do
        get "/api/v1/services?taxonomies=#{taxonomy_name}"
        response_body = JSON.parse(response.body)
        service_ids = response_body['content'].map {|c| c['id'] }
        expect(service_ids).to match_array(ids)
      end
    end

    it_behaves_like "a taxonomy filtered endpoint", "A" do
      let(:ids) { [@services[0].id, @services[2].id ]}
    end

    it_behaves_like "a taxonomy filtered endpoint", "B" do
      let(:ids) { [@services[1].id, @services[2].id ]}
    end

    it_behaves_like "a taxonomy filtered endpoint", "A,B" do
      let(:ids) { [@services[2].id ]}
    end
  end
end