class Admin::UsersController < Admin::BaseController
    def index
      @users = User.all
      @users = @users.search(params[:query]) if params[:query].present?
    end

    def new
      @user = User.new
    end

    def create
      @user = User.create(user_params)
      if @user.save
        redirect_to admin_users_path
      else
        render "new"
      end
    end

    def show
      @user = User.find(params[:id])
      @activities = PaperTrail::Version.includes(:item).order("created_at DESC").where(whodunnit: params[:id]).limit(5)
    end

    private

    def user_params
      params.require(:user).permit(
        :email,
        :admin
      )
    end
end