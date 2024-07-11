class DirectorySerializer < ActiveModel::Serializer
    def attributes(*args)
        object.attributes.symbolize_keys.except(:id, :created_at, :updated_at)
    end
end