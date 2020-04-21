class UserMailer < ApplicationMailer
    def invite_email
        @user = params[:user]
        mail(to: @user.email, subject: "You've been invited to the Buckinghamshire family information service")
    end
end
