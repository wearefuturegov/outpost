class UserMailer < ApplicationMailer
    def invite_from_admin_email
        @user = params[:user]
        @outpost_instance_name = Setting.outpost_instance_name.presence || 'Outpost'
        view_mail(
            ENV["NOTIFY_TEMPLATE_ID"],
            to: @user.email,
            subject: "You've been invited to #{@outpost_instance_name}"
        )
    end

    def invite_from_community_email
        @user = params[:user]
        @org = @user.organisation
        @outpost_instance_name = Setting.outpost_instance_name.presence || 'Outpost'
        view_mail(
            ENV["NOTIFY_TEMPLATE_ID"],
            to: @user.email,
            subject: "You've been invited to #{@outpost_instance_name}"
        )
    end

    def reset_instructions_email
        @user = params[:user]
        @token = params[:token]
        view_mail(
            ENV["NOTIFY_TEMPLATE_ID"],
            to: @user.email,
            subject: "Reset your password"
        )
    end
end
