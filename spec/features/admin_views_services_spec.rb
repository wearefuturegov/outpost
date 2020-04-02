# require "rails_helper"

# RSpec.feature "Service admin", type: :feature do

#   before(:all) do
#     Rails.application.load_seed
#   end

#   after(:all) do
#     DatabaseCleaner.clean_with(:truncation)
#   end

#   scenario "Admin views services" do
#     last_updated_service = Service.order(updated_at: :desc).first
#     visit admin_services_path
#     expect(page).to have_text(last_updated_service.name)
#   end

# end