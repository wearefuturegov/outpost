namespace :api do
    desc "Export accessibilities JSON file for testing the Outpost API"
    task create_test_data: :environment do
      file_path = Rails.root.join('public', 'accessibilities.json')
      accessibilities = Accessibility.defaults.sort_by { |a| a.downcase }
      File.open(file_path, 'w') do |file|
        file.write(json_tree(accessibilities).to_json)
      end
      puts "Accessibilities exported successfully to #{file_path}"
    end
end