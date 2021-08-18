class AccessibilitySerializer < ActiveModel::Serializer
    attribute :name
    attributes :slug

    def slug
        object.name.parameterize
    end
end