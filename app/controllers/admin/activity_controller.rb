class Admin::ActivityController < Admin::BaseController
    def index
        @activities = Snapshot.order("created_at DESC").page(params[:page])
    end
end