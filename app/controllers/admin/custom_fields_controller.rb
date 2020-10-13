class Admin::CustomFieldsController < Admin::BaseController
  before_action :user_admins_only

  def index
    @sections = CustomFieldSection.all
  end

  def new
    @section = CustomFieldSection.new
  end

  def create
    @section = CustomFieldSection.new(custom_field_section_params)
    if @section.save
      redirect_to admin_custom_fields_path, notice: "Fields have been created"
    else
      render "new"
    end
  end

  def show
    @section = CustomFieldSection.find(params[:id])
  end

  private

  def custom_field_section_params
      params.require(:custom_field_section).permit(
        :name,
        :hint,
        :public,
        custom_field_attributes: [
          :key,
          :field_type,
          :hint,
          :_destroy
        ]
      )
  end

end