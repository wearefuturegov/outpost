require 'rails_helper'

RSpec.describe Feedback, type: :model do
  subject { FactoryBot.create :feedback }
  let!(:owner) { FactoryBot.create :user, organisation: subject.service.organisation }

  it 'sends an email to the service owner' do
    expect { subject.reload.notify_owners }
      .to have_enqueued_mail(ServiceMailer, :notify_owner_of_feedback_email).once
  end

  context 'with more than one service owner' do
    let!(:owner_2) { FactoryBot.create :user, organisation: subject.service.organisation }

    it 'sends an email all service owners' do
      expect { subject.reload.notify_owners }
        .to have_enqueued_mail(ServiceMailer, :notify_owner_of_feedback_email).twice
    end
  end
end
