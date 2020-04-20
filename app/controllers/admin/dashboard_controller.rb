class Admin::DashboardController < Admin::BaseController
  
    def index
      @watches = current_user.watches
      @activities = PaperTrail::Version.order("created_at DESC").limit(5)

      @service_count = Service.count
      @user_count = User.count
      @org_count = Organisation.count
      @taxa_count = Taxonomy.count
    end
  
  end