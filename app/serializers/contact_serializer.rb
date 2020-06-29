class ContactSerializer < ActiveModel::Serializer
    def attributes(*args)
        object.attributes.symbolize_keys.except(:created_at, :updated_at, :service_id, :visible)
    end
end