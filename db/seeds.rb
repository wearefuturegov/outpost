dummy_data_yaml = Rails.root.join('db', '_dummy-data.yml')
default_data_yaml = Rails.root.join('db', '_default-data.yml')
dummy_data = YAML::load_file(dummy_data_yaml)

# This file gives us everything we need for a fresh install of the application
# Setting SEED_DUMMY_DATA will also generate fake users, services, locations etc

seed_dummy_data = ENV["SEED_DUMMY_DATA"] || false;

seed_admin_user = ENV["SEED_ADMIN_USER"] || false;

seed_default_data = ENV["SEED_DEFAULT_DATA"] || false;

# make a single super admin user
if seed_admin_user

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
        location.save
    end


    # create nested taxonomies - chance of subcategories being generated is different at each level
    def create_taxonomy(level = 0, parent_id = nil)
        return if level >= 4
      
        taxon = Taxonomy.create!({
          name: Faker::Lorem.words(number: rand(2...5)).join(' ').capitalize,
          parent_id: parent_id
        })
      
        case level
        when 0
          rand(2..10).times { create_taxonomy(level + 1, taxon.id) } if rand < 0.50
        when 1
          rand(3..15).times { create_taxonomy(level + 1, taxon.id) } if rand < 0.2
        when 2
          rand(1..3).times { create_taxonomy(level + 1, taxon.id) } if rand < 0.15
        end
    end
      
    5.times { create_taxonomy }

    10.times do
        org = Organisation.create!({
            name: Faker::Company.name,
            skip_mongo_callbacks: true
        })

        rand(0...2).times do 
            user = User.create!({
                first_name: Faker::Name.first_name,
                last_name: Faker::Name.last_name,
                email: Faker::Internet.email(domain: "example.com"),
                organisation: org,
                password: "FakePassword1!"
            })
        end

        rand(0...5).times do 
            service = Service.create!({
                name: Faker::Company.name,
                organisation: org,
                description: Faker::Lorem.paragraph,
                skip_mongo_callbacks: true
            })
            # byebug
            service.locations << Location.take
            service.taxonomies << Taxonomy.take
            service.save!
        end
    end

end