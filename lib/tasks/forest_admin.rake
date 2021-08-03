require 'csv'
namespace :forest_admin do

  MIN_AGES = {
    "young people" => nil,
    "young adults" => 18,
    "older adults" => 25
  }

  MAX_AGES = {
    "young people" => 18,
    "young adults" => 25,
    "older adults" => nil
  }

  task :import => :environment do
    start_time = Time.now

    services_file = File.open('lib/seeds/bod/services.csv', "r:utf-8")
    services_csv = CSV.parse(services_file, headers: true)

    services_csv.each.with_index do |row, line|
      service = Service.new(
        name: row["Name"],
        description: row["Description"],
        url: row["URL"],
        visible: set_visibility(row["Review status"]),
        min_age: set_min_age(row["Age groups"]),
        max_age: set_max_age(row["Age groups"]),
      )
      puts service.inspect

      contact = Contact.new(
        name: row["Contact name"],
        email: email
      )
    end

    end_time = Time.now
    puts "Took #{(end_time - start_time)/60} minutes"
  end
end

def set_visibility(review_status)
  if review_status == 'Unpublish'
    return false
  end
end

def set_min_age(age_groups)
  min_ages = []
  eval(age_groups).each do |age_group|
    min_ages << MIN_AGES[age_group]
  end
  return min_ages.include?(nil) ? nil : min_ages.compact.min
end

def set_max_age(age_groups)
  max_ages = []
  eval(age_groups).each do |age_group|
    max_ages << MAX_AGES[age_group]
  end
  return max_ages.include?(nil) ? nil : max_ages.compact.max
end