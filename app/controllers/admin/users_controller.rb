class Admin::UsersController < Admin::BaseController
    before_action :set_user, only: [:show, :update]
    
    def index
      @users = User.all
      @users = @users.community if params[:filter_users] === "community"
      @users = @users.admins if params[:filter_users] === "admins"
      @users = @users.search(params[:query]) if params[:query].present?
    end

    def new
      @user = User.new
    end

    def create
      @user = User.create(user_params)
      @user.password = SecureRandom.urlsafe_base64
      if @user.save
        UserMailer.with(user: @user).invite_from_admin_email.deliver_later
        redirect_to admin_users_path
      else
        render "new"
      end
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User has been updated"
      else
        render "show"
      end
    end

    def show
      @activities = PaperTrail::Version.includes(:item).order("created_at DESC").where(whodunnit: params[:id]).limit(5)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :email,
        :admin,
        :organisation_id
      )
    end
end