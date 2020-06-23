class IndexedServicesSerializer < ActiveModel::Serializer

  def attributes(*args)
    object.attributes.symbolize_keys.except(:label_list, :discarded_at, :marked_for_deletion, :notes_count)
  end

  has_many :locations do
    object.locations.where(visible: true)
  end

  has_many :contacts do
    object.contacts.where(visible: true)
  end
  belongs_to :organisation
  has_many :taxonomies

  def visible_from
    DateTime.strptime(object.visible_from, '%Y-%m-%d').to_time.utc if object.visible_from
  end

  def visible_to
    DateTime.strptime(object.visible_to, '%Y-%m-%d').to_time.utc if object.visible_to
  end

  class IndexedLocationSerializer < ActiveModel::Serializer
    attributes(*Location.attribute_names - ['latitude', 'longitude'] + ['geometry']).map(&:to_sym)

    def geometry
      return {
          type: "Point",
          coordinates: [object.longitude.to_f.round(2), object.latitude.to_f.round(2)]
      } if object.mask_exact_address
      object.geometry
    end

    def address_1
      return '***' if object.mask_exact_address
      object.address_1
    end
  end

  def self.serializer_for(model, options)
    return IndexedLocationSerializer if model.class == Location
    super
  end
end