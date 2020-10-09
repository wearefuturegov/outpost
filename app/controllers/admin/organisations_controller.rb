class Admin::OrganisationsController < Admin::BaseController
  before_action :set_organisation, only: [:show, :edit, :update]

  def index
    @filterrific = initialize_filterrific(
      Organisation,
      params[:filterrific],
      select_options: {
        sorted_by: Organisation.options_for_sorted_by,
        users: Organisation.options_for_users,
        services: Organisation.options_for_services
      },
      persistence_id: false,
      default_filter_params: {},
      available_filters: [
        :sorted_by, 
        :search,
        :users,
        :services
      ],
      sanitize_params: true,
    ) || return

    @organisations = @filterrific.find.page(params[:page])
  end

  def show
  end

  def edit
  end

  def timetable
    @organisation = Organisation.find(params[:organisation_id])
    render :layout => "printable"
  end

  def update
    if @organisation.update(organisation_params)
      redirect_to admin_organisation_path, notice: "Organisation has been updated."
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
      redirect_to admin_organisation_path, notice: "Organisation has been created."
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