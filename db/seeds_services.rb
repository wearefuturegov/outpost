module SeedsServices

  # each one of these represents a different status for a service 
  def self.status_services 
    {
      'pending' => {
        approved: false,
      },
      'marked_for_deletion' => {
        discarded_at: Time.now - 2.day, 
        marked_for_deletion: Time.now - 1.day
      },
      'archived' => {
        discarded_at: Time.now - 1.day
      },
      'invisible' => { 
        approved: true,
        visible: false
      },
      'scheduled' => {
        approved: true,
        visible_from: (Time.now + 100.days).strftime("%Y-%m-%d")
      },
      'expired' => {
        approved: true,
        visible_to: (Time.now - 100.days).strftime("%Y-%m-%d")
      },
      'temporarily_closed' => {
        approved: true,
        temporarily_closed: true
      },
      'active' => {
        approved: true
      }
    }
  end

  # so we have some services that are visible and some that are not
  def self.publicly_visible_services
    {
      'publicly_visible' => {
        approved: true,
        visible: true,
        discarded_at: nil
      },
      'not_publicly_visible' => {
        approved: true,
        visible: false,
        discarded_at: nil
      },
      'also_not_publicly_visible' => {
        approved: true,
        visible: true,
        discarded_at: Time.now - 1.day
      }
    }
  end

  

  def self.create_default_services

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

    services = status_services.merge(publicly_visible_services)
    5.times do
      services.each do |status, attributes|
        puts "Creating service with status: #{status}"
        service = Service.create!({
          name: "SEND peer support #{Faker::Company.name}",
          organisation: org,
          description: Faker::Lorem.paragraph,
          skip_mongo_callbacks: true
        }.merge(attributes))
        # byebug
        service.locations << Location.take
        service.taxonomies << Taxonomy.take
        service.save!
      end
    end


    # we also need some services with regular_schedules

    # Service with regular schedule
    service = Service.create!({
        name: Faker::Company.name,
        organisation: org,
        skip_mongo_callbacks: true,
        regular_schedules_attributes: [
          {
            weekday: 1, 
            opens_at: '09:00:00',
            closes_at: '17:00:00'
          }
        ]
      })
      service.locations << Location.take
      service.taxonomies << Taxonomy.take
      service.save!

    # Service with regular schedule, general schedule and at multiple locations
      location = Location.take(2)
      service = Service.create!({
        name: Faker::Company.name,
        organisation: org,
        skip_mongo_callbacks: true,
        locations: location,
      })
      service_at_location_id = service.service_at_locations.find_by(location_id: location.first.id).id
      service.regular_schedules.build ([
        {
          weekday: 1, 
          opens_at: '09:00:00',
          closes_at: '17:00:00',
          service_at_location_id: service_at_location_id
        },
        {
          weekday: 2, 
          opens_at: '09:00:00',
          closes_at: '17:00:00',
          service_at_location_id: service_at_location_id
        },
        {
          weekday: 3, 
          opens_at: '09:00:00',
          closes_at: '17:00:00',
          service_at_location_id: service_at_location_id
        },
        {
          weekday: 1, 
          opens_at: '09:00:00',
          closes_at: '17:00:00'
        }
      ])
      service.taxonomies << Taxonomy.take
      service.save!


    # Service with regular schedule only at multiple locations
    location = Location.take(2)
    service = Service.create!({
      name: Faker::Company.name,
      organisation: org,
      skip_mongo_callbacks: true,
      locations: location,
    })
    service_at_location_id_first = service.service_at_locations.find_by(location_id: location.first.id).id
    service_at_location_id_second = service.service_at_locations.find_by(location_id: location.second.id).id
    service.regular_schedules.build ([
      {
        weekday: 1, 
        opens_at: '09:00:00',
        closes_at: '17:00:00',
        service_at_location_id: service_at_location_id_first
      },
      {
        weekday: 2, 
        opens_at: '09:00:00',
        closes_at: '17:00:00',
        service_at_location_id: service_at_location_id_first
      },
      {
        weekday: 3, 
        opens_at: '09:00:00',
        closes_at: '17:00:00',
        service_at_location_id: service_at_location_id_first
      },
      {
        weekday: 1, 
        opens_at: '09:00:00',
        closes_at: '17:00:00',
        service_at_location_id: service_at_location_id_second
      },
      {
        weekday: 2, 
        opens_at: '09:00:00',
        closes_at: '17:00:00',
        service_at_location_id: service_at_location_id_second
      }
    ])
    service.taxonomies << Taxonomy.take
    service.save!

  end


  def self.create_services
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

end