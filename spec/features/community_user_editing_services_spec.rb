require 'rails_helper'

feature 'Community user managing services', type: :feature do
  let!(:service) { FactoryBot.create :service }

  before do
    user = FactoryBot.create :user
    login_as user
  end

  it 'should show page title' do

    visit service_path(service)
    expect(page).to have_content("List a new service")
  end

  # context 'Custom field section marked as public with custom fields' do
  #   FactoryBot.create :custom_field_section, public: true
  #   FactoryBot.create :custom_field
  #   it 'Show extra questions option' do
  #     expect(page).to have_content("Extra questions")
  #   end
  # end


  # context 'Custom field section marked as public with no custom fields' do
  #   FactoryBot.create :custom_field_section, public: true
  #   it 'Don\'t show extra questions option ' do
  #     expect(page).not_to have_content("Extra questions")
  #   end
  # end


  # context 'No custom field section and no custom fields' do
  #   it 'Don\'t show extra questions option ' do
  #     expect(page).not_to have_content("Extra questions")
  #   end
  # end

end
