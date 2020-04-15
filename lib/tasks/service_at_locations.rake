namespace :service_at_locations do

  desc "This fills location at service search index table"

  task :prepare => [ :environment ] do
    ServiceAtLocation.includes(:service).includes(:location).each do |service_at_location|
      service_at_location.service_id = service_at_location.service.id
      service_at_location.service_name = service_at_location.service.name
      service_at_location.service_description = service_at_location.service.description
      service_at_location.service_url = service_at_location.service.url
      service_at_location.service_email = service_at_location.service.email

      service_at_location.location_id = service_at_location.location.id
      service_at_location.postcode = service_at_location.location.postal_code
      service_at_location.latitude = service_at_location.location.latitude
      service_at_location.longitude = service_at_location.location.longitude

      service_at_location.save

    end
  end
end