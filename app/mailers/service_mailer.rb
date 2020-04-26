class ServiceMailer < ApplicationMailer
    def notify_watchers_email
        @service = params[:service]
        @service.watches.each do |w|
            mail(
                to: w.user.email, 
                subject: "A service you're watching has been updated"
            )
        end
    end
end
