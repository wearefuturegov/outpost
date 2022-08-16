yaml = Rails.root.join('db', '_seed.yml')
data = YAML::load_file(yaml)

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

data["accessibilities"].each do |n|
    Accessibility.create!({name: n})
end

data["send_needs"].each do |n|
    SendNeed.create!({name: n})
end

data["suitabilities"].each do |n|
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
            description: Faker::Lorem.paragraphs(number: 1),
            skip_mongo_callbacks: true
        })
        # byebug
        service.locations << Location.take
        service.taxonomies << Taxonomy.take
        service.save!
    end
end

# make a single admin user
User.create!({
    first_name: "Example",
    last_name: "Admin",
    admin: true,
    admin_users: true,
    admin_ofsted: true,
    email: "example@example.com",
    password: ENV["INITIAL_ADMIN_PASSWORD"] || "FakePassword1!"
})