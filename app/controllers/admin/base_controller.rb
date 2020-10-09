class Admin::BaseController < ApplicationController
    before_action :require_admin!
    before_action :set_counts, if: :should_count?

    private

    def user_admins_only
        unless current_user.admin_users? 
          redirect_to request.referer, notice: "You don't have permission to edit other users."
        end
    end

    def require_admin!
        unless current_user.admin === true
            redirect_to root_path
        end
    end

    def should_count?
        controller_name === "services" || "requests"
    end

    def set_counts
        @all_count = Service.kept.count
        @ofsted_count = Service.kept.ofsted_registered.count
        @pending_count = Service.kept.where(approved: nil).count
        @archived_count = Service.discarded.count
    end
end