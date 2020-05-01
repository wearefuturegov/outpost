class Admin::ActivityController < Admin::BaseController
    def index
        @activities = Snapshot.order("created_at DESC")
            .page(params[:page])
            .includes(:service, :user)
    end
end