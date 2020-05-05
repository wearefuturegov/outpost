require 'csv'

# Seed users from old DB
users_file = File.open('lib/seeds/users.csv', "r:ISO-8859-1")
open_objects_users_csv = CSV.parse(users_file, headers: true)

csv_file = File.open('lib/seeds/bucksfis geo.csv', "r:ISO-8859-1")
bucks_csv = CSV.parse(csv_file, headers: true)

bucks_csv.each do |row| # CREATE ORGS BASED ON TYPE
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

bucks_csv.each.with_index do |row, line|
  puts "Processing line: #{line} of #{bucks_csv.size}"

  open_objects_users = open_objects_users_csv.select{ |user_row| user_row['externalId'] == row['record_editor'] } # users from open objects csv
  outpost_users = User.where(old_external_id: row['record_editor']) # new database users already created by this seed

  if (open_objects_users.count > 1) || (outpost_users.count > 1)
    byebug # if never get here, then we know only ever one open object/outpost user
  end

# FIND OR CREATE ORG

  organisation = Organisation.where(old_external_id: row['parent_organisation']).first unless row['parent_organisation'].nil? # find from parent ID
  organisation ||= outpost_users.first&.organisation # find from user
  organisation ||= Organisation.where(old_external_id: row['externalid']).first # if for service that is also org

  if organisation.blank?
    organisation = Organisation.new
    organisation.save
  end

# CREATE USER IF DOESN'T ALREADY EXIST AND DID PREVIOUSLY
  if outpost_users.blank? & open_objects_users.any?
    open_objects_user = open_objects_users.first
    password = "A9#{SecureRandom.hex(8)}1Z"
    user = User.new
    user.email = open_objects_user['email']
    user.old_external_id = open_objects_user['externalId']
    user.first_name = open_objects_user['firstName']
    user.last_name = open_objects_user['lastName']
    user.organisation_id = organisation.id
    user.password = password
    user.save
  end

# CREATE SERVICE

  service = ChildcareService.new if row['service_type'] == 'Childcare'
  service ||= Service.new

  service.name = row['title']
  service.description = ActionView::Base.full_sanitizer.sanitize(row['description'])
  service.email = row['contact_email']
  service.url = row['website']

  service.organisation = organisation

  service.snapshot_action = "import"
  if (row['ecd_opt_out_website'] == 'Hide completely from public website') || (row['ecd_opt_out_website'] == 'Admin access only, never on website')
    service.discarded_at = Time.now
  end

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

  unless row['familychannel'] == nil
    lines = row['familychannel'].split("\n")
    lines.each do |line|
      categories = line.split(' > ')
      categories.delete("Family Information")
      parent_cateogry = categories.first
      child_category = categories.last unless categories.size == 1 # is a parent category
      parent_taxonomy = Taxonomy.find_or_create_by(name: parent_cateogry) if parent_cateogry
      child_taxonomy = Taxonomy.find_or_create_by(name: child_category, parent_id: parent_taxonomy.id) if child_category # otherwise tries to create with name nil
      service.taxonomies |= [parent_taxonomy] if parent_taxonomy
      service.taxonomies |= [child_taxonomy] if child_taxonomy
    end
  end

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

end

#Create bucks and fg users
user_logins_yaml = Rails.root.join('lib', 'seeds', 'user_logins.yml')
user_logins = YAML::load_file(user_logins_yaml)
user_logins.each do |user_login|
  User.create!(user_login) unless (User.where(email: user_login["email"]).size > 0)
end