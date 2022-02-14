class ServiceMailerPreview < ActionMailer::Preview
  def notify_watcher_email
    ServiceMailer.with(service: Watch.first.service, user: Watch.first.user).notify_watcher_email
  end

  def notify_owner_email
    ServiceMailer.with(service: Service.first, user: User.first).notify_owner_email
  end

  def notify_owner_of_feedback_email
    ServiceMailer.with(service: Feedback.first.service, feedback: Feedback.first, user: User.first).notify_owner_of_feedback_email
  end
end

