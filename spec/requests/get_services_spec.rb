require 'rails_helper'

describe 'Taxonomy queries', type: :request do

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
end