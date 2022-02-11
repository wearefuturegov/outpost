class ServiceMailer < ApplicationMailer
    add_template_helper(FeedbacksHelper)

    def notify_watcher_email
        @service = params[:service]
        user = params[:user]
        view_mail(
            ENV["NOTIFY_TEMPLATE_ID"],
            {
                to: user.email,
                subject: "A service you're watching has been updated"
            }
        )
    end

    def notify_owner_email
        @service = params[:service]
        user = params[:user]
        view_mail(
            ENV["NOTIFY_TEMPLATE_ID"],
            to: user.email,
            subject: "Your changes have been approved"
        )
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
