class UpdateIndexTaxonomiesJob < ApplicationJob
  queue_as :default

  def perform(taxon)
    client = Mongo::Client.new(ENV["MONGODB_URI"] || 'mongodb://127.0.0.1:27017/outpost_development', {
      retry_writes: false
  })
    collection = client.database[:indexed_services]
    query = collection.find({ "taxonomies.id": { "$eq": taxon.id } }, { id: 1 })
    services = Service.find(query.map { |d| d['id'] })
    services.each {|s| s.update_index }
  end
end
