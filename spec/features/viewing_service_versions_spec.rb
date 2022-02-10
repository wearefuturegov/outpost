require 'rails_helper'

feature 'Viewing service version history', type: :feature do
  let(:service) { FactoryBot.create :service }
  let!(:recent_version) { FactoryBot.create :service_version, item_type: 'Service', item_id: service.id, event: 'update', created_at: 1.day.ago }
  let!(:old_version) { FactoryBot.create :service_version, item_type: 'Service', item_id: service.id, event: 'update', created_at: 4.days.ago }

  before do
    service.versions.where(event: 'create').update(created_at: 1.week.ago)
    admin_user = FactoryBot.create :user, :services_admin
    login_as admin_user
  end

  it 'shows versions in reverse chronological order' do
    visit admin_service_path(service)

    within '#service-history' do
      expect('Updated').to appear_before('Created')
      expect('1 day ago').to appear_before('4 days ago')
    end

    click_link 'Compare versions'

    expect(recent_version.created_at.strftime('%-d %B %Y, %H:%M')).to appear_before('Created')
    expect(recent_version.created_at.strftime('%-d %B %Y, %H:%M')).to appear_before(old_version.created_at.strftime('%-d %B %Y, %H:%M'))
  end
end
