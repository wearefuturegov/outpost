class TaxonomySerializer < ActiveModel::Serializer
    attributes :id
    attributes :name
    attributes :slug
    attributes :parent_id

    def slug
        object.name.parameterize
    end
end