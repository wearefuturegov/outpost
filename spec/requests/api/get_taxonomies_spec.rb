require 'rails_helper'

describe 'GET taxonomies endpoint', type: :request do
  let(:api_endpoint) { '/api/v1/taxonomies' }

  context 'with taxonomies in the DB' do
    let!(:root_taxonomy) { FactoryBot.create(:taxonomy) }
    let!(:taxonomy_a) { FactoryBot.create(:taxonomy, name: 'category a', parent_id: root_taxonomy.id) }
    let!(:taxonomy_b) { FactoryBot.create(:taxonomy, name: 'category b', parent_id: root_taxonomy.id) }

    it 'returns taxonomies and their children' do
      get api_endpoint
      response_body = JSON.parse(response.body)

      root_taxonomy_ids = response_body.map{|taxonomy| taxonomy["id"]}
      expect(root_taxonomy_ids).to match_array([root_taxonomy.id])

      root_taxonomy_names = response_body.map{|taxonomy| taxonomy["label"]}
      expect(root_taxonomy_names).to match_array([root_taxonomy.name])

      child_taxonomies = response_body.first['children'].map{|t| t['label']}
      expect(child_taxonomies).to match_array([taxonomy_a.name, taxonomy_b.name])
    end

    context 'with directories in the DB' do
      let!(:directory_a) { FactoryBot.create(:directory, name: "Directory A", label: "a") }
      let!(:directory_b) { FactoryBot.create(:directory, name: "Directory B", label: "b") }

      let!(:directory_b_taxonomy) { FactoryBot.create(:taxonomy, directories: [directory_b]) }

      before do
        root_taxonomy.update(directories: [directory_a])
        taxonomy_a.update(directories: [directory_a])
        taxonomy_b.update(directories: [directory_a])
      end

      it 'can filter by directory' do
        get "/api/v1/taxonomies?directory=#{directory_a.label}"
        response_body = JSON.parse(response.body)

        root_taxonomy_ids = response_body.map{|taxonomy| taxonomy["id"]}
        expect(root_taxonomy_ids).to match_array([root_taxonomy.id])

        get "/api/v1/taxonomies?directory=#{directory_b.label}"
        response_body = JSON.parse(response.body)

        root_taxonomy_ids = response_body.map{|taxonomy| taxonomy["id"]}
        expect(root_taxonomy_ids).to match_array([directory_b_taxonomy.id])
      end

      context 'filtering by an empty directory' do
        let!(:directory_c) { FactoryBot.create(:directory, name: "Directory C", label: "c") }
        it 'returns no results' do
          get "/api/v1/taxonomies?directory=#{directory_c.label}"
          response_body = JSON.parse(response.body)
          expect(response_body).to match_array([])
        end
      end

      context 'filtering by a directory that does not exist' do
        it 'returns all results' do
          get "/api/v1/taxonomies?directory=not-a-real-directory"
          response_body = JSON.parse(response.body)

          root_taxonomy_ids = response_body.map{|taxonomy| taxonomy["id"]}
          expect(root_taxonomy_ids).to match_array([root_taxonomy.id, directory_b_taxonomy.id])
        end
      end
    end
  end

  context 'with no taxonomies in the DB' do
    it 'returns an empty array' do
      get api_endpoint
      response_body = JSON.parse(response.body)
      expect(response_body).to match_array([])
    end
  end
end
