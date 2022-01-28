class ServiceMailerPreview < ActionMailer::Preview
  def notify_watchers_email
    ServiceMailer.with(service: Watch.first.service).notify_watchers_email
  end

  def notify_owners_email
    ServiceMailer.with(service: Service.first).notify_owners_email
  end

  def notify_owner_of_feedback_email
    ServiceMailer.with(service: Feedback.first.service, feedback: Feedback.first).notify_owner_of_feedback_email
  end
end

