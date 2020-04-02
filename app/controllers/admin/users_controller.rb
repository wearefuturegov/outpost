class Admin::UsersController < Admin::BaseController
    def index
      @users = User.all
    end
end