class Admin::UsersController < Admin::BaseController
    before_action :user_admins_only, only: [:new, :create, :update, :destroy, :reactivate]
    before_action :set_user, only: [:show, :update, :destroy]
    
    def index
      @query = params.permit(:deactivated, :order, :order_by, :filter_users, :filter_logged_in, :query)

      @users = User.includes(:organisation).page(params[:page]).order("last_seen DESC  NULLS LAST")

      if params[:deactivated] === "true"
        @users = @users.discarded
      else
        @users = @users.kept
      end

      @users = @users.rarely_seen if params[:order] === "asc" && params[:order_by] === "last_seen"
      @users = @users.latest_seen if params[:order] === "desc" && params[:order_by] === "last_seen"
      @users = @users.newest if params[:order] === "desc" && params[:order_by] === "created_at"
      @users = @users.oldest if params[:order] === "asc" && params[:order_by] === "created_at"  

      @users = @users.community if params[:filter_users] === "community"
      @users = @users.admins if params[:filter_users] === "admins"
      @users = @users.never_seen if params[:filter_logged_in] === "never"
      @users = @users.only_seen if params[:filter_logged_in] === "only"

      @users = @users.search(params[:query]) if params[:query].present?

      @active_count = User.kept.count
      @deactivated_count = User.discarded.count
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
        redirect_to admin_user_path(@user), notice: "User has been updated."
      else
        render "show"
      end
    end

    def show
      @activities = Snapshot.order("created_at DESC").where(user: params[:id]).limit(5).includes(:service)
    end

    def destroy
      unless @user === current_user
        @user.discard
        redirect_to admin_users_path, notice: "That user has been deactivated."
      else
        redirect_to admin_user_path(@user), notice: "You can't deactivate yourself."
      end
    end

    def reactivate
      User.find(params[:user_id]).undiscard
      redirect_to request.referer, notice: "That user has been reactivated."
    end

    def reset
      @user = User.find(params[:user_id])
      token = @user.send(:set_reset_password_token)
      UserMailer.with(token: token, user: @user).reset_instructions_email.deliver_later
      redirect_to admin_user_path(@user), notice: "Password reset instructions have been sent by email."
    end

    private

    def user_admins_only
      unless current_user.admin_users? 
        redirect_to request.referer, notice: "You don't have permission to edit other users."
      end
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :email,
        :first_name,
        :last_name,
        :admin,
        :admin_ofsted,
        :admin_users,
        :organisation_id
      )
    end
end