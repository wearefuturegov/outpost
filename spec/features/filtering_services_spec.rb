require 'rails_helper'

feature 'Filtering services' do
  scenario 'filtering works' do
    search_term = 'Aurora borealis'
    service_a = FactoryBot.create :service, name: search_term
    service_b = FactoryBot.create :service

    admin_user = FactoryBot.create :user, :services_admin
    login_as admin_user

    visit admin_services_path
    fill_in 'filterrific_search', with: search_term
    find('#test-search').click

    expect(page).to have_content service_a.name
    expect(page).to_not have_content service_b.name
  end

  scenario 'a name match carries more weight than a description match' do
    search_term_a = 'Aurora borealis'
    search_term_b = 'Chicken schnitzel'
    service_a = FactoryBot.create :service, name: search_term_a, description: search_term_b
    service_b = FactoryBot.create :service, name: search_term_b, description: search_term_a

    admin_user = FactoryBot.create :user, :services_admin
    login_as admin_user
    visit admin_services_path

    fill_in 'filterrific_search', with: search_term_a
    find('#test-search').click

    within('.test-services') do
      expect(service_a.name).to appear_before(service_b.name)
    end

    click_link 'Clear search'
    fill_in 'filterrific_search', with: search_term_b
    find('#test-search').click

    within('.test-services') do
      expect(service_b.name).to appear_before(service_a.name)
    end
  end
end
