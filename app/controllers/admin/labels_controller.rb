class Admin::LabelsController < Admin::BaseController

    def index
        @query = params.permit(:order, :order_by)

        @labels = ActsAsTaggableOn::Tag.most_used

        @labels = @labels.reorder("updated_at ASC") if params[:order] === "asc" && params[:order_by] === "updated_at"
        @labels = @labels.reorder("updated_at DESC") if params[:order] === "desc" && params[:order_by] === "updated_at"
    end

    def destroy
        @label = ActsAsTaggableOn::Tag.find(params[:id])
        @label.destroy
        redirect_to admin_labels_path, notice: "That label has been removed."
    end

    private

end