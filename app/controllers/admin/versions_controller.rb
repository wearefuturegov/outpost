class Admin::VersionsController < Admin::BaseController
    def index
        @versions = Service.find(params[:service_id]).versions.reverse
    end
end