class OrganisationSerializer < ActiveModel::Serializer
    def attributes(*args)
        object.attributes.symbolize_keys.except(:created_at, :updated_at, :users_count, :services_count, :old_external_id)
    end
end