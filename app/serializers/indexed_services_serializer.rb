class IndexedServicesSerializer < ActiveModel::Serializer

  def attributes(*args)
    object.attributes.symbolize_keys.except(
      :visible, 
      :notes_count, 
      :ofsted_reference_number,                              
      :old_ofsted_external_id, 
      :ofsted_item_id, 
      :organisation_id, 
      :approved,                              
      :label_list, 
      :discarded_at, 
      :marked_for_deletion
    )
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

    attribute :name
    attribute :description
    attribute :address_1
    attribute :city
    attribute :state_province
    attribute :postal_code
    attribute :country
    attribute :google_place_id
    attribute :geometry

    def geometry
      return {
          type: "Point",
          coordinates: [object.longitude.to_f.round(2), object.latitude.to_f.round(2)]
      } if object.mask_exact_address
      object.geometry
    end

    def address_1
      return nil if object.mask_exact_address
      object.address_1
    end

    def postal_code
      if object.mask_exact_address and object.postal_code
        return UKPostcode.parse("W1A 2AB").outcode
      end
      object.postal_code
    end
  end

  class IndexedContactsSerializer < ActiveModel::Serializer
    def attributes(*args)
      object.attributes.symbolize_keys.except(:id, :created_at, :updated_at, :service_id, :visible)
    end
  end

  class IndexedTaxonomySerializer < ActiveModel::Serializer
    def attributes(*args)
      object.attributes.symbolize_keys.except(:id, :created_at, :updated_at, :locked)
    end
  end

  class IndexedOrganisationSerializer < ActiveModel::Serializer
    def attributes(*args)
      object.attributes.symbolize_keys.except(:created_at, :updated_at, :users_count, :services_count, :old_external_id)
    end
  end

  def self.serializer_for(model, options)
    return IndexedLocationSerializer if model.class == Location
    return IndexedContactsSerializer if model.class == Contact
    return IndexedTaxonomySerializer if model.class == Taxonomy
    return IndexedOrganisationSerializer if model.class == Organisation
    super
  end
end