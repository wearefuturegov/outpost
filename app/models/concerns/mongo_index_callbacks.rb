module MongoIndexCallbacks

    extend ActiveSupport::Concern

    attr_accessor :skip_mongo_callbacks

    included do
        after_save :update_index, unless: :skip_mongo_callbacks
    end

    def update_index
        client = Mongo::Client.new(ENV["MONGODB_URI"] || 'mongodb://127.0.0.1:27017/outpost_development', {
            retry_writes: false
        })
        collection = client.database[:indexed_services]
        if self.approved? && self.publicly_visible?
            collection.find_one_and_update({id: self.id}, IndexedServicesSerializer.new(self).as_json, {upsert: true})
        elsif !self.approved? && self.last_approved_snapshot&.publicly_visible?
            collection.find_one_and_update({id: self.id}, IndexedServicesSerializer.new(Service.from_hash(self.last_approved_snapshot.object)).as_json, {upsert: true})
        else
            collection.find_one_and_delete({id: self.id})
        end
    end
end