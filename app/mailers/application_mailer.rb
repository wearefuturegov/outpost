class ApplicationMailer < ActionMailer::Base
  default from: ENV["MAILER_FROM"] || 'CHANGEME@CHANGEME.com'
  layout 'mailer'
end
