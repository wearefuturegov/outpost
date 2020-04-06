class Admin::DashboardController < Admin::BaseController
  
    def index
      @watches = current_user.watches
    end
  
  end