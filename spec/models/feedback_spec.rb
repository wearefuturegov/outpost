require 'rails_helper'

RSpec.describe Feedback, type: :model do
  subject { FactoryBot.create :feedback }
  let!(:owner) { FactoryBot.create :user, organisation: subject.service.organisation }

  it { should validate_presence_of :topic }
  it { should validate_presence_of :body }

  describe '#notify_owners' do
    it 'sends an email to the service owner' do
      expect { subject.reload.notify_owners }
        .to have_enqueued_mail(ServiceMailer, :notify_owner_of_feedback_email).once
    end

    context 'with more than one service owner' do
      let!(:owner_2) { FactoryBot.create :user, organisation: subject.service.organisation }

      it 'sends an email to all service owners' do
        expect { subject.reload.notify_owners }
          .to have_enqueued_mail(ServiceMailer, :notify_owner_of_feedback_email).twice
      end
    end

    context 'with a deactivated service owner' do
      let!(:discarded_owner) { FactoryBot.create :user, organisation: subject.service.organisation, discarded_at: 1.day.ago }

      it 'sends an email only to active users' do
        expect { subject.reload.notify_owners }
          .to have_enqueued_mail(ServiceMailer, :notify_owner_of_feedback_email).once
      end
    end
  end
end
