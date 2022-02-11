require 'rails_helper'

RSpec.describe Feedback, type: :model do
  subject { FactoryBot.create :feedback }
  let!(:owner) { FactoryBot.create :user, organisation: subject.service.organisation }

  it 'sends an email to the service owner' do
    expect { subject.notify_owners }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by 1
  end

  context 'with more than one service owner' do
    let!(:owner_2) { FactoryBot.create :user, organisation: subject.service.organisation }

    it 'sends an email all service owners' do
      expect { subject.notify_owners }
        .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by 2
    end
  end
end
