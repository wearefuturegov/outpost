class ServiceMailer < ApplicationMailer
    add_template_helper(FeedbacksHelper)

    def notify_watchers_email
        @service = params[:service]
        @service.watches.each do |w|
            view_mail(
                ENV["NOTIFY_TEMPLATE_ID"],
                to: w.user.email,
                subject: "A service you're watching has been updated"
            )
        end
    end

    def notify_owners_email
        @service = params[:service]
        @service.organisation.users.each do |u|
            view_mail(
                ENV["NOTIFY_TEMPLATE_ID"],
                to: u.email, 
                subject: "Your changes have been approved"
            )

        end
    end

    def notify_owner_of_feedback_email
        @service = params[:service]
        @feedback = params[:feedback]
        @service.organisation.users.each do |u|
            view_mail(
                ENV["NOTIFY_TEMPLATE_ID"],
                to: u.email, 
                subject: "There's new feedback on your service"
            )
        end
    end
end
