class Admin::BaseController < ApplicationController
  before_action :require_admin!
  before_action :set_pending_counts
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
    controller_name === "services" || controller_name === "requests"
  end

  def set_pending_counts
    # Since we don't want to count everything unnecessarily we do these two earlier
    # these two relate to badges on the ui  - see _navigation.html.erb
    @ofsted_counts = {
      all: {
        pending: OfstedItem.where.not(status: nil).count
      }
    }
    @service_counts = {
      all: {
        pending: Service.kept.where(approved: nil).count
      }
    }
  end

  def set_counts
    # Update, don't override @service_counts from set_pending_counts
    @service_counts[:all][:all] = Service.kept.count
    @service_counts[:all][:ofsted] = Service.kept.ofsted_registered.count
    @service_counts[:all][:archived] = Service.discarded.count

    Directory.find_each do |directory|
      @service_counts[directory.name] = {
        all: directory.services.kept.count,
        ofsted: directory.services.kept.ofsted_registered.count,
        pending: directory.services.kept.where(approved: nil).count,
        archived: directory.services.discarded.count
      }
    end
  end

end
