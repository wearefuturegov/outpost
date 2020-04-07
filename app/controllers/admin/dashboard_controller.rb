class Admin::DashboardController < Admin::BaseController
  
    def index
      @watches = current_user.watches
      @service_count = Service.count
      @user_count = User.count
    end
  
  end