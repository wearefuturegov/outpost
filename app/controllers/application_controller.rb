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
      # Since we don't want to count everything unnecessarily we do these two earlier
      # these two relate to badges on the ui  - see _navigation.html.erb
      @ofsted_counts = {
        all: {
          pending: OfstedItem.where.not(status: nil).count
        }
      };
      @service_counts = {
        all: {
          pending: Service.kept.where(approved: nil).count
        }
      };
    end
end