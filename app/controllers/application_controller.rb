class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :set_pending_counts
    around_action :set_current_user

    protected

    # def after_sign_in_path_for(resource)
    #     admin_root_path
    # end 

    # def after_sign_up_path_for(resource)
    #     '/organisations'
    # end

    def set_current_user
      Current.user = current_user
      yield
    ensure
      Current.user = nil
    end  

    def no_admins
      if current_user && current_user.admin?
        redirect_to admin_root_path, notice: "You're logged in as an administrator, so you can't access that part of the site right now."
      end
    end

    def set_pending_counts
      @ofsted_pending_count = OfstedItem.where.not(status: nil).count
      @pending_count = Service.kept.where(approved: false).count
    end
end