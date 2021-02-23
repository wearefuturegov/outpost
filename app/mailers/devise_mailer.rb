class DeviseMailer < Devise::Mailer
  def devise_mail(record, action, opts = {}, &block)
    initialize_from_record(record)
    view_mail(ENV['NOTIFY_TEMPLATE_ID'], headers_for(action, opts))
  end
end