require 'rails_helper'

RSpec.describe 'Managing taxonomies', type: :feature do
  before do
    admin_user = FactoryBot.create :user, :full_admin
    login_as admin_user
    visit admin_taxonomies_path
  end

  context 'creating a new taxonomy' do
    let(:name) { Faker::Lorem.sentence }
    let(:invalid_name) { '' }

    it 'works' do
      fill_in :taxonomy_name, with: name
      click_button 'Create'
      expect(page).to have_content 'Taxonomy has been created'
      expect(page).to have_content name
    end

    it 'shows any errors' do
      fill_in :taxonomy_name, with: invalid_name
      click_button 'Create'
      expect(page).to have_content 'can\'t be blank'
    end
  end
end
