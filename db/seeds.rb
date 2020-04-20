# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

csv_file = File.open('lib/seeds/bucksfis geo.csv', "r:ISO-8859-1")
bucks_csv = CSV.parse(csv_file, headers: true)

services_with_org = 0
services_without_org = 0

bucks_csv.each do |row|

  if row['service_type'] == 'Organisation'
    organisation = Organisation.new
    organisation.name = row['title']
    organisation.description = ActionView::Base.full_sanitizer.sanitize(row['description'])
    organisation.email = row['contact_email']
    organisation.url = row['website']
    organisation.old_external_id = row['externalid']
    organisation.save
  end
end

bucks_csv.each do |row|
  # if row['title'] == "'The Heroes Academy' Holiday Club | 19 to 21 Feb (Half Term)"
  #   byebug
  # end
  if row['service_type'] != "Organisation"
    service = Service.new
    service.name = row['title']
    service.description = ActionView::Base.full_sanitizer.sanitize(row['description'])
    service.email = row['contact_email']
    service.url = row['website']
    if parent_organisation = Organisation.where(old_external_id: row['parent_organisation']).first
      service.organisation_id = parent_organisation.id
    else
      organisation = Organisation.new # Create organisation if doeesnt exist
      organisation.save
      service.organisation_id = organisation.id
    end
    service.paper_trail_event = 'import'
    service.save

    contact = Contact.new
    contact.service_id = service.id
    contact.name = row['contact_name']
    contact.title = row['contact_position']
    contact.save

    phone = Phone.new
    phone.contact_id = contact.id
    phone.number = row['contact_telephone']
    phone.save

    if row['venue_name'].present? && (Location.where('lower(name) = ?', row['venue_name'].downcase).size > 0) # Assign location if already exists
      service.locations << Location.where('lower(name) = ?', row['venue_name'].downcase).first
    else # Otherwise create a new one
      location = Location.new
      location.name = row['venue_name']
      location.address_1 = [row['venue_address_1'], row['venue_address_2']].join(' ')
      location.city = row['venue_address_4']
      location.state_province = 'Buckinghamshire'
      location.postal_code = row['venue_postcode']
      location.latitude = row['latitude']
      location.longitude = row['longitude']
      location.country = 'GB'
      location.save
      service.locations << location
    end
    service.save
  end
end