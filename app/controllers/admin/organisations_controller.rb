class Admin::OrganisationsController < Admin::BaseController
  before_action :set_organisation, only: [:show, :edit, :update]

  def index
    @query = params.permit(:order, :order_by, :filter_users, :filter_services, :query)

    @organisations = Organisation.page(params[:page])
      .includes(:services, :users)
      .page(params[:page])

    @organisations = @organisations.alphabetical if params[:order] === "asc" && params[:order_by] === "name"
    @organisations = @organisations.reverse_alphabetical if params[:order] === "desc" && params[:order_by] === "name"
    @organisations = @organisations.newest if params[:order] === "desc" && params[:order_by] === "updated_at"
    @organisations = @organisations.oldest if params[:order] === "asc" && params[:order_by] === "updated_at"

    @organisations = @organisations.only_with_services if params[:filter_services] === "with"
    @organisations = @organisations.only_with_users if params[:filter_users] === "with"

    @organisations = @organisations.only_with_users if params[:filter_users] === "with"
    @organisations = @organisations.only_without_users if params[:filter_users] === "without"

    @organisations = @organisations.search(params[:query]) if params[:query].present?
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
      redirect_to admin_organisations_path, notice: "Organisation has been created."
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