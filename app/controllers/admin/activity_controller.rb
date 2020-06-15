class Admin::ActivityController < Admin::BaseController
    def index
        @activities = Snapshot.order("created_at DESC")
            .page(params[:page])
            .includes(:service, :user)
        
        @activities = @activities.where(user: params[:filter_user]) if params[:filter_user]
    end

    def show
        @activities = Snapshot.order("created_at DESC")
            .page(params[:page])
            .includes(:service, :user)
            .where(user: params[:id])

        render :index
    end
end