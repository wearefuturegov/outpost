require 'rails_helper'

feature 'Viewing feedback', type: :feature do
  before do
    admin_user = FactoryBot.create :user, :services_admin
    login_as admin_user
  end

  it 'works' do
    service = FactoryBot.create :service
    feedback = FactoryBot.create :feedback, service: service
    
    visit '/admin/feedbacks'
    expect(page).to have_content feedback.body
  end
end
