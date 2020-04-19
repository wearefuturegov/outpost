class Admin::RequestsController < Admin::BaseController
    def index
        @requests = Approval::Request.all.reverse
    end
end