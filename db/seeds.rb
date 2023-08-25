yaml = Rails.root.join('db', '_seed.yml')
yaml_default_data = Rails.root.join('db', '_default-data.yml')
data = YAML::load_file(yaml)
default_data = YAML::load_file(yaml_default_data)

# use our realistic sample UK data - fake data won't correctly geocode
data["locations"].each do |l|
    Location.create!({
        address_1: l["address_1"],
        city: l["city"],
        postal_code: l["postal_code"],
        latitude: l["latitude"],
        longitude: l["longitude"],
        skip_mongo_callbacks: true
    })
end

default_data["accessibilities"].each do |n|
    Accessibility.create!({name: n})
end

default_data["send_needs"].each do |n|
    SendNeed.create!({name: n})
end

default_data["suitabilities"].each do |n|
    Suitability.create!({name: n})
end

10.times do 
    taxon = Taxonomy.create!({
        name: Faker::Lorem.words(number: rand(1...5)).join(' ').capitalize
    })
end

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

# make a single super admin user
User.find_or_create_by!(email: ENV["INITIAL_ADMIN_EMAIL"] || "example@example.com") do |user|
    user.first_name = "Example"
    user.last_name = "Admin"
    user.admin = true
    user.admin_users = true
    user.admin_ofsted = true
    user.superadmin = true
    user.admin_manage_ofsted_access = true
    user.email = ENV["INITIAL_ADMIN_EMAIL"] || "example@example.com"
    user.password = ENV["INITIAL_ADMIN_PASSWORD"] || "FakePassword1!"
end
