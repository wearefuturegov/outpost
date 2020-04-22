class MembersController < ApplicationController

    def new
        @user = User.new
    end

    def create
        @user = current_user.organisation.users.build(user_params)
        @user.password = SecureRandom.urlsafe_base64
        if @user.save
            UserMailer.with(user: @user).invite_from_community_email.deliver_later
            redirect_to organisations_path, notice: "User invited successfully. They'll get an email telling them what to do next"
        else
            render 'new'
        end
    end

    private

    def user_params
        params.require(:user).permit(
            :email
        )
    end

end