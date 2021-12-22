require 'rails_helper'

feature 'Admin managing services', type: :feature do
  let!(:organisation) { FactoryBot.create :organisation }
  let!(:suitabilities) { FactoryBot.create_list :suitability, 5 }

  before do
    admin_user = FactoryBot.create :user, :services_admin
    login_as admin_user
    visit admin_services_path
  end

  scenario 'I can create a service' do
    service_name = Faker::Company.name

    click_link_or_button('Add service')

    expect(page).to have_content("Add a new service")

    fill_in('Name', with: service_name)
    select(organisation.name, from: :service_organisation_id)
    click_link_or_button('Create')

    expect(page).to have_content("Service has been created")
    expect(page).to have_content(service_name)
    expect(page).to have_content(organisation.name)
  end

  context 'with an existing service' do
    let!(:service) { FactoryBot.create :service }

    scenario 'I can edit an existing service' do
      visit admin_services_path
      click_link service.name
      check suitabilities.first.name
      click_link_or_button 'Update'

      expect(page).to have_content("Service has been updated")
      expect(service.reload.suitabilities.count).to eq(1)
    end
  end

  scenario 'I can browse services by directory' do
    bfis = FactoryBot.create(:directory, name: "Family Information Service", label: "bfis")
    bod = FactoryBot.create(:directory, name: "Buckinghamshire Online Directory", label: "bod")
    FactoryBot.create_list(:service, 4, directories: [bfis])
    FactoryBot.create_list(:service, 2, directories: [bod])

    visit admin_services_path

    expect(page).to have_content 'All (6)'
    expect(page).to have_content 'Family Information Service (4)'
    expect(page).to have_content 'Buckinghamshire Online Directory (2)'
  end
end
