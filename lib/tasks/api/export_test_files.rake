# It may seem counter intuitive but this rake task is used to export JSON files for testing the Outpost API.
# Since most of the data 'defaults' live in outpost any way it makes sense to have some functionality to export the data for testing purposes.
# Plus updating huge JSON files is a pain
# docker compose exec outpost bin/rake api:export_test_files:all
require 'json'
namespace :api do
  namespace :export_test_files do


    # Scout uses 6 json files for tests to mimic the API endpoints
    # REACT_APP_FILTERS_DATASOURCE - aka outpost
    # accessibilities.json
    # send_needs.json
    # suitabilities.json
    # taxonomies.json

    # REACT_APP_API_HOST - aka outpost-api
    # services.json
    # service.json


    desc "Export accessibilities JSON file for testing the Outpost API"
    task accessibilities: :environment do
      file_path = Rails.root.join('public', 'accessibilities.json')
      accessibilities = Accessibility.defaults.sort_by { |a| a.downcase }
      File.open(file_path, 'w') do |file|
        file.write(json_tree(accessibilities).to_json)
      end
      puts "Accessibilities exported successfully to #{file_path}"
    end

    desc "Export send_needs JSON file for testing the Outpost API"
    task send_needs: :environment do
      file_path = Rails.root.join('public', 'send_needs.json')
      send_needs = SendNeed.defaults.sort_by { |a| a.downcase }
      File.open(file_path, 'w') do |file|
        file.write(json_tree(send_needs).to_json)
      end
      puts "Send needs exported successfully to #{file_path}"
    end

    desc "Export suitabilities JSON file for testing the Outpost API"
    task suitabilities: :environment do
      file_path = Rails.root.join('public', 'suitabilities.json')
      suitabilities = Suitability.defaults.sort_by { |a| a.downcase }
      File.open(file_path, 'w') do |file|
        file.write(json_tree(suitabilities).to_json)
      end
      puts "Suitabilities exported successfully to #{file_path}"
    end

    desc "Export taxonomies JSON file for testing the Outpost API"
    task :taxonomies do
      file_path = Rails.root.join('public', 'taxonomies.json')
      dummy_data_yaml = Rails.root.join('db', '_dummy-data.yml')
      dummy_data = YAML::load_file(dummy_data_yaml)
      taxonomies = dummy_data["taxonomies"]
      File.open(file_path, 'w') do |file|
        file.write(taxonomies_json_tree(taxonomies).to_json)
      end
      puts "Taxonomies exported successfully to #{file_path}"
      # Your logic here
    end

    desc "Export services JSON file for testing the Outpost API"
    task :services do
      puts "services..."
      # Your logic here
    end

    desc "Export service JSON file for testing the Outpost API"
    task :service do
      puts "service..."
      # Your logic here
    end


    desc "Export JSON files for testing the Outpost API"
    task :all => [:accessibilities, :send_needs, :suitabilities, :taxonomies, :services, :service] do
      puts "Exporting all JSON files..."
      # Your main task logic here
    end
  end
end



def json_tree(options)
  options.each_with_index.map do |a, i|
    {
      id: i+1,
      label: a,
      slug: a.parameterize
    }
  end
end

def taxonomies_json_tree(taxonomies, depth = 0)
  taxonomies.map.with_index do |(t, children), i|
     id = depth === 0 ? i+1 : "#{i+1}#{depth}#{rand(0...1000)}".to_i
      {
          id: id,
          label: t["name"],
          slug: t["name"].parameterize,
          level: depth,
          children: t["children"].nil? ? [] : taxonomies_json_tree(t["children"], depth + 1)
      }
  end
end




# def accessibilities
#   Accessibility.all.map(&:name)
# end

# def send_needs
#   SendNeed.all.map(&:name)
# end

# def suitabilities
#   Suitability.all.map(&:name)
# end

# def taxonomies
#   Taxonomy.all.map(&:name)
# end

# def services
#   Service.all.map(&:name)
# end

# def service
#   Service.all.map(&:name)
# end

