class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :set_pending_counts
    before_action :set_paper_trail_whodunnit

    protected

    def no_admins
      if current_user && current_user.admin?
        redirect_to admin_root_path
      end
    end

    def set_pending_counts
      @ofsted_pending_count = OfstedItem.where.not(status: nil).count
      @pending_count = Service.kept.where(approved: nil).count
    end
end