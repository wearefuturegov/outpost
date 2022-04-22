require 'rails_helper'

RSpec.describe IndexedServicesSerializer do
  let!(:service) { FactoryBot.create :service }
  subject { described_class.new(service) }

  context 'without any associations' do

    it 'includes attributes' do
      expect(subject.attributes.keys).to contain_exactly(:id,
        :updated_at,
        :name,
        :description,
        :url,
        :visible_from,
        :visible_to,
        :min_age,
        :max_age,
        :age_band_under_2,
        :age_band_2,
        :age_band_3_4,
        :age_band_5_7,
        :age_band_8_plus,
        :age_band_all,
        :needs_referral,
        :free,
        :created_at,
        :status)
    end
  end
end
