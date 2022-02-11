class Feedback < ApplicationRecord
  belongs_to :service

  validates_presence_of :topic
  validates_presence_of :body  

  after_save :notify_owners

  paginates_per 20

  def notify_owners
    self.service.organisation.users.kept.each do |user|
      ServiceMailer.with(feedback: self, service: self.service, user: user).notify_owner_of_feedback_email.deliver_later
    end
  end
end
