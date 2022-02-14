require 'rails_helper'

feature 'Viewing Ofsted items', type: :feature do
  let(:ofsted_item) { FactoryBot.create :ofsted_item }
  let!(:recent_version) { FactoryBot.create :service_version, item_type: 'OfstedItem', item_id: ofsted_item.id, event: 'update', created_at: 1.day.ago }
  let!(:old_version) { FactoryBot.create :service_version, item_type: 'OfstedItem', item_id: ofsted_item.id, event: 'update', created_at: 4.days.ago }

  before do
    ofsted_item.versions.where(event: 'create').update(created_at: 1.week.ago)
    admin_user = FactoryBot.create :user, :ofsted_viewer
    login_as admin_user
  end

  it 'shows versions in reverse chronological order' do
    visit admin_ofsted_path(ofsted_item)

    within '#service-history' do
      expect('Updated').to appear_before('Created')
      expect('1 day ago').to appear_before('4 days ago')
    end

    click_link 'Compare versions'

    expect(recent_version.created_at.strftime('%-d %B %Y, %H:%M')).to appear_before('Created')
    expect(recent_version.created_at.strftime('%-d %B %Y, %H:%M')).to appear_before(old_version.created_at.strftime('%-d %B %Y, %H:%M'))
  end
end
