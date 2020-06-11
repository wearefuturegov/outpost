class MembersController < ApplicationController
    before_action :no_admins
    skip_before_action :no_admins, only: [:destroy]
    
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

    def destroy
        @user = User.find(params[:id])
        @user.discard
        redirect_to organisations_path, notice: "That user has been removed and won't be able to log in any more."
    end

    private

    def user_params
        params.require(:user).permit(
            :email,
            :first_name,
            :last_name
        )
    end

end