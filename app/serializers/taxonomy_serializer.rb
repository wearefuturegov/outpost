class TaxonomySerializer < ActiveModel::Serializer
    def attributes(*args)
        object.attributes.symbolize_keys.except(:created_at, :updated_at, :locked)
    end
end
