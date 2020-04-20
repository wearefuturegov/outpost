class Admin::ActivityController < Admin::BaseController
    def index
        @activities = PaperTrail::Version
            .includes(:item)
            .order("created_at DESC")
            .page(params[:page])
    end
end