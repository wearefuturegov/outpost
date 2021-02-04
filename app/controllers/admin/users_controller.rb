class Admin::UsersController < Admin::BaseController
    before_action :user_admins_only, only: [:new, :create, :update, :destroy, :reactivate]
    before_action :set_user, only: [:show, :update, :destroy]
    
    def index
      @filterrific = initialize_filterrific(
        User,
        params[:filterrific],
        select_options: {
          sorted_by: User.options_for_sorted_by,
          roles: User.options_for_roles,
          tagged_with: Service.options_for_labels
        },
        persistence_id: false,
        default_filter_params: {},
        available_filters: [
          :sorted_by, 
          :search,
          :roles,
          :tagged_with
        ],
        sanitize_params: true,
      ) || return
  
      @users = @filterrific.find.page(params[:page])

      @active_count = User.kept.count
      @deactivated_count = User.discarded.count

      # shortcut nav
      if params[:deactivated] === "true"
        @users = @users.discarded
      else
        @users = @users.kept
      end
    end

    def new
      @user = User.new
    end

    def create
      @user = User.create(user_params)
      @user.password = SecureRandom.urlsafe_base64
      if @user.save
        UserMailer.with(user: @user).invite_from_admin_email.deliver_later
        redirect_to admin_users_path, notice: "User has been invited."
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
      @activities = PaperTrail::Version.order("created_at DESC").where(whodunnit: params[:id]).limit(5)
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
        :organisation_id,
        :label_list,
      )
    end
end