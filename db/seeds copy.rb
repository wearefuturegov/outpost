dummy_data_yaml = Rails.root.join('db', '_dummy-data.yml')
dummy_data = YAML::load_file(dummy_data_yaml)

# This file gives us everything we need for a fresh install of the application
# Setting SEED_DUMMY_DATA will also generate fake users, services, locations etc

seed_dummy_data = ENV["SEED_DUMMY_DATA"] || false;

seed_admin_user = ENV["SEED_ADMIN_USER"] || false;

seed_default_data = ENV["SEED_DEFAULT_DATA"] || false;

# make a single super admin user
if seed_admin_user

    puts "Seeding admin user..."

    User.find_or_create_by!(email: "example@example.com") do |user|
        user.first_name = "Example"
        user.last_name = "Admin"
        user.admin = true
        user.admin_users = true
        user.admin_ofsted = true
        user.superadmin = false
        user.admin_manage_ofsted_access = true
        user.email = "example@example.com"
        user.password = ENV["INITIAL_ADMIN_PASSWORD"] || "FakePassword1!"
    end

end


if seed_default_data

    puts "Seeding default data..."

    Accessibility.defaults.each do |n|
        Accessibility.find_or_create_by!({name: n})
    end

    SendNeed.defaults.each do |n|
        SendNeed.find_or_create_by!({name: n})
    end

    Suitability.defaults.each do |n|
        Suitability.find_or_create_by!({name: n})
    end

end


if seed_dummy_data

    puts "Seeding dummy data..."

    # use our realistic sample UK data - fake data won't correctly geocode
    dummy_data["locations"].each do |l|
        location = Location.find_or_create_by!({
            address_1: l["address_1"],
            city: l["city"],
            postal_code: l["postal_code"],
            latitude: l["latitude"],
            longitude: l["longitude"]
        }) do |loc|
            loc.skip_mongo_callbacks = true
        end
        location.skip_mongo_callbacks = true
        location.save
    end

    # create taxonomies
    def create_default_taxonomies(taxonomies, parent_id = nil)
        taxonomies.each do |taxonomy|
            parent = Taxonomy.find_or_create_by!(name: taxonomy["name"], parent_id: parent_id)
            next unless taxonomy["children"]
        
            taxonomy["children"].each do |child|
            if child.is_a?(Hash)
                create_default_taxonomies([child], parent.id)
            else
                Taxonomy.find_or_create_by!(name: child, parent_id: parent.id)
            end
            end
        end
    end

    create_default_taxonomies(dummy_data["taxonomies"])

    # create organisations (and add some users to them)
    dummy_data["organisations"].each do |o|
        organisation = Organisation.find_or_create_by!(name: o["name"]) do |org|
            org.skip_mongo_callbacks = true
        end
        organisation.skip_mongo_callbacks = true
        organisation.save

        rand(0...2).times do 
            user = User.create!({
                first_name: Faker::Name.first_name,
                last_name: Faker::Name.last_name,
                email: Faker::Internet.email(domain: "example.com"),
                organisation: organisation,
                password: "FakePassword1!"
            })
        end
    end

    default_org =  Organisation.find_by(name: dummy_data["organisations"][0]["name"]);
    default_location =  Location.find_by(address_1: dummy_data["locations"][0]["address_1"]);
    second_location = Location.find_by(address_1: dummy_data["locations"][1]["address_1"]);
    default_taxonomy = Taxonomy.find_by(name: dummy_data["taxonomies"][0]["name"]);
    regular_schedule_attributes = {
        weekday: 1, 
        opens_at: '09:00:00',
        closes_at: '17:00:00'
    }
    dummy_data["services"].each do |s|
        service = Service.find_or_create_by!({
            name: s["name"]
            }) do |srv|
            srv.skip_mongo_callbacks = true
            srv.description = s["description"];
            srv.approved = s["approved"] unless s["approved"].nil?
            srv.organisation = s["organisation_index"].nil? ?  default_org : Organisation.find_by(name: dummy_data["organisations"][s["organisation_index"].to_i]["name"])
            srv.marked_for_deletion = s["marked_for_deletion"] unless s["marked_for_deletion"].nil?
            srv.discarded_at = s["discarded_at"] unless s["discarded_at"].nil?
            srv.visible_from = s["visible_from"] unless s["visible_from"].nil?
            srv.visible_to = s["visible_to"] unless s["visible_to"].nil?
            srv.temporarily_closed = s["temporarily_closed"] unless s["temporarily_closed"].nil?
            srv.visible = s["visible"] unless s["visible"].nil?

            if s["taxonomies"].nil?
                srv.taxonomies << default_taxonomy
            else 
                s["taxonomies"].each do |t|
                    srv.taxonomies << Taxonomy.find_by(name: t)
                end
            end


            case s["regular_schedule_type"]
            when "all_locations"
                srv.locations = [default_location] 
            when "all_specific_locations", "specific_locations"
                puts "multiple locations"
                srv.locations = [default_location, second_location] 
            end

        end
        service.skip_mongo_callbacks = true


        
        case s["regular_schedule_type"] 
        when "all_locations"
            service.regular_schedules.create!(regular_schedule_attributes)
        when "all_specific_locations"
            service.regular_schedules.create!(regular_schedule_attributes)

            service_at_location = service.service_at_locations
            service_at_location.each do |sal|
                service.regular_schedules.create!(regular_schedule_attributes.merge({ service_at_location_id: sal.id }))
            end
        when "specific_locations"
            service_at_location = service.service_at_locations
            service_at_location.each do |sal|
                service.regular_schedules.create!(regular_schedule_attributes.merge({ service_at_location_id: sal.id }))
            end
        end


        service.save
    end
end