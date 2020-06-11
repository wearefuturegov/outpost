task :mongo => :environment  do
    # initial population of index
    IndexedServiceAtLocation.destroy_all
    
    results = ServiceAtLocation.joins(:service)
        .limit(100)
        .where(services: {approved: true})
        .each do |result|

            indexed = IndexedServiceAtLocation.find_or_initialize_by({
                name: result.service.name,
                description: result.service.description,
                taxonomies: result.taxonomies.map{ |t| t.name },
                street_address: result.location.address_1
            })
            indexed.save

            puts "#{result.service.name} indexed"
        end
end