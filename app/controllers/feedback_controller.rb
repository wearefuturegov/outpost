class FeedbackController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_service
  before_action :redirect_if_admin!

  def index
    @feedback = @service.feedbacks.new
  end

  def create
    @feedback = @service.feedbacks.build(feedback_params)
    if @feedback.save
      render "create"
    else
      render "index"
    end
  end

  private

  def set_service
    @service = Service.find(params[:service_id])
  end

  def redirect_if_admin!
    redirect_to admin_service_path(@service) if current_user&.admin?
  end

  def feedback_params
    params.require(:feedback).permit(
      :body,
      :topic
    )
  end
end
