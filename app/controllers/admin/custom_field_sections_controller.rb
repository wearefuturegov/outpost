class Admin::CustomFieldSectionsController < Admin::BaseController
  before_action :user_admins_only
  before_action :set_section, only: [:show, :update, :destroy]

  def index
    @sections = CustomFieldSection.all
  end

  def new
    @section = CustomFieldSection.new
  end

  def create
    @section = CustomFieldSection.new(custom_field_section_params)
    if @section.save
      redirect_to admin_custom_field_sections_path, notice: "Fields have been created."
    else
      render "new"
    end
  end

  def show
  end

  def update
    if @section.update(custom_field_section_params)
      redirect_to admin_custom_field_section_path(@section), notice: "Fields have been updated."
    else
      render "show"
    end
  end

  def destroy
    @section.destroy
    redirect_to admin_custom_field_sections_path, notice: "Those fields has been removed."
  end

  private

  def set_section
    @section = CustomFieldSection.find(params[:id])
  end

  def custom_field_section_params
      params.require(:custom_field_section).permit(
        :name,
        :hint,
        :public,
        :sort_order,
        custom_fields_attributes: [
          :id,
          :key,
          :field_type,
          :hint,
          :_destroy
        ]
      )
  end

end