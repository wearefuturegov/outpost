class TaxonomySerializer < ActiveModel::Serializer

    attributes :name
    attributes :slug

    def slug
        object.name.parameterize
    end

end