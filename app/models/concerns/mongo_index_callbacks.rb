module MongoIndexCallbacks

    extend ActiveSupport::Concern

    attr_accessor :skip_mongo_callbacks

    included do
        after_commit :update_index, if: -> { skip_mongo_callbacks != true }
    end

    def update_index
        UpdateIndexServicesJob.perform_later(self)
    end

    def update_this_service_in_index
        if self.approved? && self.publicly_visible?
            client = get_mongo_client
            collection = client.database[:indexed_services]
            collection.find_one_and_update({id: self.id}, IndexedServicesSerializer.new(self).as_json, {upsert: true})
            client.close
        elsif self.approved && !self.publicly_visible?
            client = get_mongo_client
            collection = client.database[:indexed_services]
            collection.find_one_and_delete({id: self.id})
            client.close
        end
    end

    def get_mongo_client
        client = Mongo::Client.new(ENV["DB_URI"] || 'mongodb://localhost:27017/outpost_development?authSource=admin', {
            retry_writes: false
        })
    end
end