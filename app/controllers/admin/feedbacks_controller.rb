class Admin::FeedbacksController < Admin::BaseController
    def index
        @feedbacks = Feedback.order(created_at: :desc).includes(:service).page(params[:page])
    end
end