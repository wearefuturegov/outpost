class Admin::CustomFieldsController < Admin::BaseController
  before_action :user_admins_only
  before_action :set_fields_and_new_field, only: [:index, :create]

  def index
  end

  def create
    @new_field = CustomField.create(custom_field_params)
    if @new_field.save
      redirect_to admin_custom_fields_path, notice: "Field has been created."
    else
      render "index"
    end
  end

  def destroy
    CustomField.find(params[:id]).destroy
    redirect_to admin_custom_fields_path, notice: "Field has been removed."
  end

  private

  def set_fields_and_new_field
    @fields = CustomField.all
    @new_field = CustomField.new
  end

  def custom_field_params
      params.require(:custom_field).permit(
        :key,
        :field_type,
        :hint,
        :public
      )
  end

  end