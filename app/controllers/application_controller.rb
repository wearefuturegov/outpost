class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    # before_action :set_paper_trail_whodunnit
    around_action :set_current_user

    protected

    def after_sign_in_path_for(resource)
        admin_root_path
    end 

    def after_sign_up_path_for(resource)
        '/organisations'
    end

    def set_current_user
      Current.user = current_user
      yield
    ensure
      Current.user = nil
    end  
end