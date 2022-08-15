require 'rails_helper'

RSpec.describe ServiceMeta, type: :model do
  subject { FactoryBot.create :service_meta, service: FactoryBot.create(:service) }

  it { should validate_presence_of(:key) }
  it { should validate_uniqueness_of(:key).scoped_to(:service_id) }
end
