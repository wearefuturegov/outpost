class UserMailer < ApplicationMailer
    def invite_from_admin_email
        @user = params[:user]
        mail(to: @user.email, subject: "You've been invited to the Buckinghamshire Family Information Service")
    end

    def invite_from_community_email
        @user = params[:user]
        @org = @user.organisation
        mail(to: @user.email, subject: "You've been invited to the Buckinghamshire Family Information Service")
    end

    def reset_instructions_email
        @user = params[:user]
        @token = params[:token]
        mail(to: @user.email, subject: "Reset your password")
    end
end
