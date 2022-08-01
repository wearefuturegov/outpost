namespace :services do
    desc 'Output a list of all the data contained in the delimited fields'
    task :display_delimited_field_values => :environment do
      file_path = Rails.root.join('lib', 'seeds', 'tvp-services.csv')
      
      file = File.open(file_path, "r:ISO-8859-1")
      csv_parser = CSV.parse(file, headers: true)

      # 'service_taxonomies'
      data = csv_parser.select{|item| !item['service_taxonomies'].nil?}
      taxonomies = data.map{|i| i['service_taxonomies']}.uniq.join(';').split(';').collect(&:strip).reject(&:empty?).uniq.sort
      puts "# 👉🏻 The final list of taxonomies will be: \n\n#{taxonomies.join("\n")}" if taxonomies.length > 0 

      # 'location_accessibilities
      data = csv_parser.select{|item| !item['location_accessibilities'].nil?}
      location_accessibilities = data.map{|i| i['location_accessibilities']}.uniq.join(';').split(';').collect(&:strip).reject(&:empty?).uniq.sort
      puts "\n\n" if (location_accessibilities.length > 0)
      puts "# 👉🏻  The final list of location_accessibilities will be: \n\n#{location_accessibilities.join("\n")}" if location_accessibilities.length > 0


      # 'labels
      data = csv_parser.select{|item| !item['labels'].nil?}
      labels = data.map{|i| i['labels']}.uniq.join(';').split(';').collect(&:strip).reject(&:empty?).uniq.sort
      puts "\n\n" if (labels.length > 0)
      puts "# 👉🏻  The final list of labels will be: \n\n#{labels.join("\n")}" if labels.length > 0


      # 'suitabilities
      data = csv_parser.select{|item| !item['suitabilities'].nil?}
      suitabilities = data.map{|i| i['suitabilities']}.uniq.join(';').split(';').collect(&:strip).reject(&:empty?).uniq.sort
      puts "\n\n" if (suitabilities.length > 0)
      puts "# 👉🏻  The final list of suitabilities will be: \n\n#{suitabilities.join("\n")}" if suitabilities.length > 0 if

      # 'send_needs_support
      data = csv_parser.select{|item| !item['send_needs_support'].nil?}
      send_needs_support = data.map{|i| i['send_needs_support']}.uniq.join(';').split(';').collect(&:strip).reject(&:empty?).uniq.sort
      puts "\n\n" if (send_needs_support.length > 0)
      puts "# 👉🏻  The final list of send_needs_support will be: \n\n#{send_needs_support.join("\n")}" if send_needs_support.length > 0


      # find any custom fields that would be delimited

      custom_delimited_fields = csv_parser.headers.filter{|i| i.start_with?( 'custom_select_') }
      custom_delimited_fields.each do | field_name, i |
        
        field_data =  csv_parser.select{|item| !item[field_name].nil?}
        field_data_tidied = field_data.map{|i| i[field_name]}.uniq.join(';').split(';').collect(&:strip).reject(&:empty?).uniq.sort
        puts "\n\n" if (i != 0 && field_data_tidied.length > 0)
        puts "# 👉🏻  The final list of #{field_name} will be: \n\n#{field_data_tidied.join("\n")}" if field_data_tidied.length > 0
        puts "\n\nCopy to custom_fields.csv: \n#{field_data_tidied.join(",")}" if field_data_tidied.length > 0
      end

    end
  
  end