class IndexedServicesSerializer < ActiveModel::Serializer
  
  TARGET_DIRECTORY_MAP = {
      'bod': 'Buckinghamshire Online Directory',
      'bfis': 'Family Information Service',
  }

  attributes :id, 
    :updated_at, 
    :name, 
    :description, 
    :url, 
    :visible_from, 
    :visible_to, 
    :min_age, 
    :max_age, 
    :age_band_under_2, 
    :age_band_2, 
    :age_band_3_4,
    :age_band_5_7,
    :age_band_8_plus,
    :age_band_all,
    :needs_referral,
    :free,
    :created_at,
    :status

  has_many :target_directories do 
    object.labels.where(["name = ? or name = ?", *TARGET_DIRECTORY_MAP.values]).map do |directory| 
      { id: directory.id, name: directory.name, label: TARGET_DIRECTORY_MAP.key(directory.name) }
    end
  end
  
  has_many :locations do
    object.locations.where(visible: true)
  end

  has_many :contacts do
    object.contacts.where(visible: true)
  end

  has_many :meta do
    meta_to_serialise = []
    object.meta.each do |m|
      should_serialise = CustomField.find_by(key: m.key)&.custom_field_section&.api_public
      meta_to_serialise << m if should_serialise
    end
    meta_to_serialise
  end

  belongs_to :organisation

  has_many :taxonomies
  has_many :regular_schedules
  has_many :cost_options
  has_many :links
  has_many :send_needs
  has_many :suitabilities

  has_one :local_offer, unless: -> { object.local_offer&.marked_for_destruction? }

  def visible_from
    object.visible_from.strftime('%Y-%m-%d').to_time.utc if object.visible_from
  end

  def visible_to
    object.visible_to.strftime('%Y-%m-%d').to_time.utc if object.visible_to
  end

end