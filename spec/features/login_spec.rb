require 'rails_helper'

feature "logging in" do
    let(:user) { FactoryBot.create(:user) }

    def fill_in_fields
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: user.password
        click_button "Log in"
    end

    scenario "visit site to sign in" do
        visit root_path
        fill_in_fields
        expect(page).to have_content("Signed in successfully")
    end
    
end