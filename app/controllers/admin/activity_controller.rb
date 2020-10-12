class Admin::ActivityController < Admin::BaseController
    def index
        @activities = PaperTrail::Version.order("created_at DESC").page(params[:page])
        @activities = @activities.where(whodunnit: params[:user]) if params[:user]
    end
end