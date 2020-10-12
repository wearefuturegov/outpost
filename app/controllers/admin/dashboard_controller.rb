class Admin::DashboardController < Admin::BaseController
  
    def index
      @watches = current_user.watches.includes(:service)
      @activities = PaperTrail::Version.limit(5).order(created_at: :desc)

      @service_count = Service.count
      @user_count = User.count
      @org_count = Organisation.count
      @taxa_count = Taxonomy.count
    end
  
  end