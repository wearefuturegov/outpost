require 'rails_helper'

feature 'Managing pending service update requests' do
  let!(:service) { FactoryBot.create :service, approved: nil }
  let(:service_name) { service.display_name.truncate(25) }
  let!(:service_owners) { FactoryBot.create_list :user, 2, organisation: service.organisation }

  before do
    admin_user = FactoryBot.create :user, :services_admin
    login_as admin_user
    visit admin_services_path
  end

  it 'can approve pending requests' do
    click_link 'Pending'

    expect(page).to have_content service_name
    expect(page).to have_content 'Pending (1)'

    click_link 'Approve'

    expect(page).to_not have_content service_name
    expect(page).to have_content 'Pending (0)'
  end

  it 'approving a request notifies the owners' do
    click_link 'Pending'
    expect { click_link 'Approve' }
      .to have_enqueued_mail(ServiceMailer, :notify_owners_email).twice
  end

end
