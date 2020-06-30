class TaxonomySerializer < ActiveModel::Serializer

    attributes :name
    attributes: slug

    def slug
        name.parameterize
    end

end