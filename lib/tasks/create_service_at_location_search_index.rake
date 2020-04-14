namespace :create_service_at_location_search_item do

  desc "This fills location at service search index table"

  task :do_it => [ :environment ] do
    ServiceAtLocation.includes(:service).includes(:location).each do |service_at_location|

      service_at_location_search_item = ServiceAtLocationSearchItem.new

      service_at_location_search_item.service_id = service_at_location.service.id
      service_at_location_search_item.service_name = service_at_location.service.name
      service_at_location_search_item.service_description = service_at_location.service.description
      service_at_location_search_item.service_url = service_at_location.service.url

      service_at_location_search_item.location_id = service_at_location.location.id
      service_at_location_search_item.location_postal_code = service_at_location.location.postal_code
      service_at_location_search_item.location_latitude = service_at_location.location.latitude
      service_at_location_search_item.location_longitude = service_at_location.location.longitude

      service_at_location_search_item.save

    end
  end
end
