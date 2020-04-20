class Admin::ActivityController < Admin::BaseController
    def index
        @activities = PaperTrail::Version.order("created_at DESC")
    end
end