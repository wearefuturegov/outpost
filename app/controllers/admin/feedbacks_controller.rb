class Admin::FeedbacksController < Admin::BaseController

    def index
        @feedbacks = Feedback.order(created_at: :desc).page(params[:page])
    end

    private

end