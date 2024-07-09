module SeedsLocations
  def self.create_locations(locations)
    locations.each do |l|
        location = Location.find_or_create_by!({
            address_1: l["address_1"],
            city: l["city"],
            postal_code: l["postal_code"],
            latitude: l["latitude"],
            longitude: l["longitude"]
        }) do |loc|
            loc.skip_mongo_callbacks = true
        end
        location.save
    end
  end
end