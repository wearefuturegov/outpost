require 'rails_helper'

RSpec.describe ServiceAtLocation, type: :model do
 let!(:organisation) { FactoryBot.create(:organisation_with_services) }

  it "updates service at location with service" do
    service = organisation.services.first
    service.name = 'New updated name'
    service.save
    service_at_location = service.service_at_locations.first
    expect(service_at_location.service_name).to eq('New updated name')
  end

end