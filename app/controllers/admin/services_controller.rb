class Admin::ServicesController < Admin::BaseController
  def index
    @services = Service.order(updated_at: :asc)
  end
end