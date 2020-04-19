class Admin::WatchController < Admin::BaseController
    def create
        current_user.watches.create(service_id: params[:service_id])
        current_user.save
        redirect_to admin_service_path(params[:service_id])
    end
    
    def destroy
        current_user.watches.find_by(service_id: params[:id]).destroy
        redirect_to admin_service_path
    end
end