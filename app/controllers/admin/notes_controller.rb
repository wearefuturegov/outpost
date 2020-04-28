class Admin::NotesController < Admin::BaseController
    before_action :set_service

    def create
        @note = @service.notes.new(note_params)
        @note.user = current_user
        if @note.save
            redirect_to admin_service_path(@service)
        end
    end

    def destroy
        @note = current_user.notes.find(params[:id]).destroy
        redirect_to admin_service_path(@service)
    end

    private

    def set_service
        @service = Service.find(params[:service_id])
    end

    def note_params
        params.require(:note).permit(
            :body
        )
    end
end