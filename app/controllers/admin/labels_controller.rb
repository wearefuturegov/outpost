class Admin::LabelsController < Admin::BaseController
    def index
        @labels = ActsAsTaggableOn::Tag.order(:name)
    end

    def destroy
        @label = ActsAsTaggableOn::Tag.find(params[:id])
        @label.destroy
        redirect_to admin_labels_path, notice: "That label has been removed."
    end
end
