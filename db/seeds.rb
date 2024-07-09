require_relative 'seeds_locations'
require_relative 'seeds_taxonomies'
require_relative 'seeds_services'

dummy_data_yaml = Rails.root.join('db', '_dummy-data.yml')
default_data_yaml = Rails.root.join('db', '_default-data.yml')
dummy_data = YAML::load_file(dummy_data_yaml)

# This file gives us everything we need for a fresh install of the application

# Setting SEED_DUMMY_DATA will also generate fake users, services, locations etc
seed_dummy_data = ENV["SEED_DUMMY_DATA"] || false;

# Setting SEED_ADMIN_USER will create a single super admin user
seed_admin_user = ENV["SEED_ADMIN_USER"] || false;

# Setting SEED_DEFAULT_DATA will create default data for accessibilities, send_needs, and suitabilities
seed_default_data = ENV["SEED_DEFAULT_DATA"] || false;


def create_default_services(services)

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


    # We want a service to represent each status
    # for services to be publically visible they must have both visible: TRUE and discarded_at: null
    # services that use regular schedule

end










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

    # use our realistic sample UK data to create some locations - fake data won't correctly geocode
    # SeedsLocations.create_locations(dummy_data["locations"])

    # create default taxonomies
    # SeedsTaxonomies.create_default_taxonomies(dummy_data["taxonomies"])

    # create more taxonomies
    # SeedsTaxonomies.create_taxonomies()

    # create some specific services to make sure we cover test cases when developing
    SeedsServices.create_default_services()

    # add some more services
    # SeedsServices.create_services()

end


