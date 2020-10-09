class Admin::ServicesController < Admin::BaseController
  before_action :set_service, only: [:show, :update, :destroy]

  def index

    # @services = @services.tagged_with(params[:filter_label]) if params[:filter_label].present?

    @filterrific = initialize_filterrific(
      Service,
      params[:filterrific],
      select_options: {
        sorted_by: Service.options_for_sorted_by,
        in_taxonomy: Taxonomy.options_for_select,
        with_status: Service.options_for_status
      },
      persistence_id: false,
      default_filter_params: {},
      available_filters: [:in_taxonomy, :with_status, :search, :sorted_by],
    ) or return

    @services = @filterrific.find.page(params[:page])
    @services = @services.ofsted_registered if params[:ofsted] === "true"

    if params[:archived] === "true"
      @services = @services.discarded
    else
      @services = @services.kept
    end

  end

  def show
    @watched = current_user.watches.where(service_id: @service.id).exists?
    @snapshots = @service.snapshots.order(created_at: :desc).includes(:user)
    if @service.snapshots.length > 4
      @snapshots = @snapshots.first(3)
      @snapshots.push(@service.snapshots.last)
    end
  end

  def update
    # byebug
    if @service.update(service_params)
      redirect_to admin_service_url(@service), notice: "Service has been updated."
    else
      render "show"
    end
  end

  def new
    @service = Service.new
    @ofsted_item = OfstedItem.find(params[:ofsted_item_id]) if params[:ofsted_item_id]
  end

  def create
    @service = Service.new(service_params)
    if @service.save
      redirect_to admin_service_url(@service), notice: "Service has been created."
    else
      render "new"
    end
  end

  def destroy
    @service.archive
    redirect_to admin_services_path, notice: "That service has been archived."
  end

  private

  def set_service
    @service = Service.includes(notes: [:user], snapshots: [:user]).find(params[:id])
  end

  def service_params
    result_params = params.require(:service).permit(
      :name,
      :organisation_id,
      :description,
      :url,
      :referral_url,
      :facebook_url, 
      :twitter_url, 
      :youtube_url, 
      :instagram_url, 
      :linkedin_url,
      :visible,
      :visible_from,
      :visible_to,
      :min_age,
      :max_age,
      :label_list,
      :bccn_member,
      :current_vacancies,
      :pick_up_drop_off_service,
      :needs_referral,
      :marked_for_deletion,
      :free,
      :ofsted_item_id,
      taxonomy_ids: [],
      local_offer_attributes: [
        :id,
        :description,
        :link,
        :_destroy,
        survey_answers: [
          :question,
          :answer
        ]
      ],
      cost_options_attributes: [
        :id,
        :option,
        :amount,
        :_destroy,
      ],
      regular_schedules_attributes: [
        :id,
        :opens_at,
        :closes_at,
        :weekday,
        :_destroy,
      ],
      contacts_attributes: [
        :id,
        :name,
        :title,
        :visible,
        :email,
        :phone,
        :_destroy,
      ],
      links_attributes: [
        :id,
        :label,
        :url,
        :_destroy
      ],
      locations_attributes: [
        :id,
        :name,
        :address_1,
        :city,
        :postal_code,        
        :visible,
        :mask_exact_address,
        # :latitude,
        # :longitude,
        # :google_place_id,
        :_destroy,
        accessibility_ids: []
      ],
      meta_attributes: [
        :id,
        :key,
        :value
      ]
    )

    # map fields_for submitted values, which are of the form 'id => { answer: text }' into an array of '[{ id: id, answer: text }]'
    if result_params['local_offer_attributes']&.[]('survey_answers')
      result_params['local_offer_attributes']['survey_answers'] =
          result_params['local_offer_attributes']['survey_answers'].to_h.map{|k,v| { id: k.to_i, answer: v['answer']}}
    end

    result_params
  end

end