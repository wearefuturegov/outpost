class Admin::UsersController < Admin::BaseController
    def index
      @users = User.all
      @users = @users.search(params[:query]) if params[:query].present?
    end

    def new
      @user = User.new
    end

    def create
      @user = Service.create(user_params)
      if @user.save
        redirect_to admin_users_path
      else
        render "new"
      end
    end

    private

    def user_params
      params.require(:user).permit(
        :email,
        :admin
      )
    end

end