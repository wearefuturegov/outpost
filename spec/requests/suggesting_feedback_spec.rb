require 'rails_helper'

describe 'Suggesting feedback', type: :request do
  let(:service) { FactoryBot.create :service }
  let(:admin) { FactoryBot.create :user, :services_admin }

  context 'logged out' do
    it 'renders the feedback form' do
      get "/services/#{service.id}/feedback"
      expect(response).to_not redirect_to admin_service_path service
      expect(response.body).to include 'Suggest an edit'
    end
  end

  context 'logged in as an admin' do
    it 'redirects to the service edit page' do
      sign_in admin
      get "/services/#{service.id}/feedback"
      expect(response).to redirect_to admin_service_path service
    end
  end
end
