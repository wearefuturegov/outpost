require 'rails_helper'

describe 'Accessibilities endpoint', type: :request do

  before do
    # @organisation = FactoryBot.create(:organisation)
    @accessibilities = FactoryBot.create_list(:accessibility, 10)

    # root_taxonomy = Taxonomy.create(name: 'Categories')
    # taxonomy_a = Taxonomy.create(name: 'A', parent_id: root_taxonomy.id)
    # taxonomy_b = Taxonomy.create(name: 'B', parent_id: root_taxonomy.id)

    # @services[0].taxonomies << taxonomy_a
    # @services[1].taxonomies << taxonomy_b

    # @services[2].taxonomies << taxonomy_a
    # @services[2].taxonomies << taxonomy_b
  end
  it 'returns accessibilities' do
    get "/api/v1/accessibilities"
    response_body = JSON.parse(response.body)
    accessibility_ids = response_body.map{|accessibility| accessibility["id"]}
    expect(accessibility_ids).to match_array(@accessibilities.map {|accessibility| accessibility.id})
    accessibility_names = response_body.map{|accessibility| accessibility["label"]}
    expect(accessibility_names).to match_array(@accessibilities.map {|accessibility| accessibility.name})
  end
end