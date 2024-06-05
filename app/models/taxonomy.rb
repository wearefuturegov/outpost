class Taxonomy < ApplicationRecord

    has_closure_tree order: 'sort_order', 
        dependent: :destroy, 
        numeric_order: true

    has_many :service_taxonomies, dependent: :destroy
    has_many :services, -> { distinct }, through: :service_taxonomies

    has_and_belongs_to_many :directories, -> { distinct }

    attr_accessor :skip_mongo_callbacks
    after_commit :update_index, if: -> { skip_mongo_callbacks == !true }
    
    validates_presence_of :name, uniqueness: true
    validates :name, length: { minimum: 2, maximum: 100 }

    scope :filter_by_directory, -> (directory) { joins(:directories).where(directories: { name: directory }) }
    
    def slug
        name.parameterize
    end

    def update_index
        # makes sure it doesn't enqueue the job if we can't connect to the client
        # client = get_mongo_client
        # return unless client
        # client.close
        # UpdateIndexTaxonomiesJob.perform_later(self)
    end

    def get_mongo_client
        begin
            client = Mongo::Client.new(ENV["DB_URI"] || 'mongodb://localhost:27017/outpost_development?authSource=admin', {
                retry_writes: false
            })
        rescue Mongo::Error::NoServerAvailable, Mongo::Error::SocketError => e
            puts "Failed to connect to MongoDB server: #{e.message}"
            nil
        end
    end
end
