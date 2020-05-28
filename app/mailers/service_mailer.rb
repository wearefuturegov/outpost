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

    def notify_owners_email
        @service = params[:service]
        @service.organisation.users.each do |u|
            mail(
                to: u.email, 
                subject: "Your changes have been approved"
            )
        end
    end

    def notify_owner_of_feedback_email
        @service = params[:service]
        @service.organisation.users.each do |u|
            mail(
                to: u.email, 
                subject: "There's new feedback on your service"
            )
        end
    end
end
