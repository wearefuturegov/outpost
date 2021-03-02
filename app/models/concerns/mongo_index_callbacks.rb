module MongoIndexCallbacks

    extend ActiveSupport::Concern

    attr_accessor :skip_mongo_callbacks

    included do
        #after_save :update_index, if: -> { skip_mongo_callbacks != true }
    end

    def update_index
        client = Mongo::Client.new(ENV["DB_URI"] || 'mongodb://localhost:27017/outpost_development?authSource=admin', {
            retry_writes: false
        })
        collection = client.database[:indexed_services]

        # is the most recent approved version publicly visible?
        if self.approved? && self.publicly_visible?
            collection.find_one_and_update({id: self.id}, IndexedServicesSerializer.new(self).as_json, {upsert: true})
        
        # if not, is the last approved snapshot publicly visible?
        elsif !self.approved? && self.last_approved_snapshot && self.last_approved_snapshot&.object['visible'] && self.last_approved_snapshot&.object['discarded_at'].nil?
            collection.find_one_and_update({id: self.id}, IndexedServicesSerializer.new(Service.from_hash(self.last_approved_snapshot.object)).as_json, {upsert: true})
        
        # if not, delete it from the index
        else
            collection.find_one_and_delete({id: self.id})
        end

    end
end