class Admin::DashboardController < Admin::BaseController
  
    def index
      @watches = current_user.watches.includes(service: [:taxonomies])
      @activities = Snapshot.limit(5).order(created_at: :desc).includes([:user])

      @service_count = Service.count
      @user_count = User.count
      @org_count = Organisation.count
      @taxa_count = Taxonomy.count
    end
  
  end