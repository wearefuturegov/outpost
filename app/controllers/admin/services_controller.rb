class Admin::ServicesController < Admin::BaseController
  before_action :set_service, only: [:update, :destroy]
  before_action :load_custom_field_sections, only: [:show, :update, :destroy, :new, :create]
  skip_before_action :set_counts, only: :show

  def index
    @filterrific = initialize_filterrific(
      Service,
      params[:filterrific],
      select_options: {
        sorted_by: Service.options_for_sorted_by,
        in_taxonomy: Taxonomy.options_for_select,
        with_status: Service.options_for_status,
        tagged_with: Service.options_for_labels
      },
      persistence_id: false,
      default_filter_params: {},
      available_filters: [
        :in_taxonomy, 
        :tagged_with, 
        :with_status, 
        :search, 
        :sorted_by
      ],
    ) or return

    @services = @filterrific.find.page(params[:page]).includes(:organisation, :service_taxonomies, :taxonomies)
    
    @services = @services.in_directory(params[:directory]) if params[:directory].present?

    # shortcut nav
    @services = @services.ofsted_registered if params[:ofsted] === "true"
    if params[:archived] === "true"
      @services = @services.discarded
    else
      @services = @services.kept
    end

  end

  def show
    @service = Service.includes(:organisation, :contacts, :cost_options, :feedbacks, :links,
                                :local_offer, :locations, :regular_schedules,
                                notes: [user: :watches], versions: [user: :watches]).find(params[:id])

    @watched = current_user.watches.where(service_id: @service.id).exists?
    @organisations = Organisation.all
    @suitabilities = Suitability.all
    @send_needs = SendNeed.all
    @accessibilities = Accessibility.all
    @directories = Directory.all

    if @service.versions.length > 4
      @versions = @service.versions.first(3)
      @versions.push(@service.versions.last)
    else
      @versions = @service.versions
    end
  end

  def update
    # force paper trail version to be saved
    @service.updated_at = Time.now
    if @service.update(service_params)
      redirect_to admin_service_url(@service), notice: "Service has been updated."
    else
      render "show"
    end
  end

  def new
    @service = Service.new
    @organisations = Organisation.all
    @accessibilities = Accessibility.all
    @send_needs = SendNeed.all
    @suitabilities = Suitability.all
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
    @service = Service.find(params[:id])
  end

  def load_custom_field_sections
    @custom_field_sections = CustomFieldSection.includes(:custom_fields).visible_to(current_user)
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
      :temporarily_closed,

      :age_band_under_2,
      :age_band_2,
      :age_band_3_4,
      :age_band_5_7,
      :age_band_8_plus,
      :age_band_all,
      
      :label_list,
      :needs_referral,
      :marked_for_deletion,
      :free,
      :ofsted_item_id,
      directory_ids: [],
      taxonomy_ids: [],
      send_need_ids: [],
      suitability_ids: [],
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
        :cost_type,
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
        :preferred_for_post,
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
