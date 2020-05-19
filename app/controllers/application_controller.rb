class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :set_ofsted_pending_count
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

    def no_admins
      redirect_to admin_root_path if current_user.admin?
    end

    def set_ofsted_pending_count
      @ofsted_pending_count = OfstedService.ofsted_pending.count
    end
end