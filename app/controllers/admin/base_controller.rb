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
          @service_counts = {
            all: {
              all: Service.kept.count,
              ofsted: Service.kept.ofsted_registered.count,
              pending: Service.kept.where(approved: nil).count,
              archived: Service.discarded.count
            }
          }
      
          if APP_CONFIG["directories"].present?
            APP_CONFIG["directories"].each do |directory|
              service = Service.in_directory(directory["value"])
              @service_dir_counts = {
                all: service.kept.count,
                ofsted: service.kept.ofsted_registered.count,
                pending: service.kept.where(approved: nil).count,
                archived: service.discarded.count
              }
              @service_counts[directory["value"]] = @service_dir_counts
            end
          end

    end
end