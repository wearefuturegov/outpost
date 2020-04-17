class Admin::OrganisationsController < Admin::BaseController
  before_action :set_organisation, only: [:show, :edit, :update]

  def index
    @organisations = Organisation.includes(:services)
      .page(params[:page])
      .order("updated_at ASC")
  end

  def show
  end

  def edit
  end

  def update
    if @organisation.update(organisation_params)
      redirect_to admin_organisation_path
    else
      render "show"
    end
  end

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.create(organisation_params)
    if @organisation.save
      redirect_to admin_organisations_path
    else
      render "new"
    end
  end

  private

  def set_organisation
    @organisation = Organisation.find(params[:id])
  end

  def organisation_params
    params.require(:organisation).permit(
      :name
    )
  end
end