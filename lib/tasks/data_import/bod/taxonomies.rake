namespace :bod do
  namespace :taxonomy do

    TAXONOMY_MAPPING = {
      "active" => ["Staying active"],
      "social" => ["Things to do"],
      "learning" => ["Education and learning"],
      "transport" => ["Advice and support", "Transport"],
      "support" => ["Advice and support"],
      "elderly-services" => ["Advice and support", "For older people"],
      "health-wellbeing-disability-support" => ["Advice and support", "Health and wellbeing"],
      "faith-groups" => ["Advice and support", "Faith groups"],
      "cultural" => ["Things to do"],
      "befriending" => ["Advice and support", "Befriending"],
      "older people" => ["Advice and support", "For older people"],
      "faith groups" => ["Advice and support", "Faith groups"],
      "foodbanks" => ["Advice and support", "Foodbanks"],
      "corona-entertainment" => ["Advice and support", "Staying at home due to coronavirus"],
      "coronavirus" => ["Advice and support", "Staying at home due to coronavirus"],
      "corona-shopping" => ["Advice and support", "Staying at home due to coronavirus"],
      "corona-prescription" => ["Advice and support", "Staying at home due to coronavirus"],
      "corona-food-collection-delivery" => ["Advice and support", "Staying at home due to coronavirus"],
      "corona-pets" => ["Advice and support", "Staying at home due to coronavirus"],
      "corona-corona-entertainment" => ["Advice and support", "Staying at home due to coronavirus"],
      #"pastoral and spiritual" => ,
      "health-health-wellbeing-disability-support-disability-support" => ["Advice and support", "Health and wellbeing"],
      "ccorona-food-collection-delivery" => ["Advice and support", "Staying at home due to coronavirus"],
      "environment" => ["Environment"]
    }

    task :import => :environment do
      #services_file = File.open('lib/seeds/bod/services.csv', "r:utf-8")
      services_file = File.open('lib/seeds/bod/services.csv', "r:ISO-8859-1")
      services_csv = CSV.parse(services_file, headers: true)
      uniq_taxonomies = []
      services_csv.each.with_index do |row, line|
        service = Service.where(old_open_objects_external_id: row["Asset ID"]).first
        service ||= Service.where('lower(name) = ?', row["Name"]&.strip.downcase).first # apply bod taxonomy to duplicates

        if service.present?
          apply_taxonomies(service, row)
        else
          puts "No service found for asset ID #{row["Asset ID"]}"
        end
      end
    end

    task :apply_to_duplicates => :environment do
      csv_file = File.open('lib/seeds/bod/duplicates.csv', "r:utf-8")
      duplicates_csv = CSV.parse(csv_file, headers: true)

      duplicates_csv.each.with_index do |row, line|
        if row["Dir"] == "BOD"
          service = Service.find(row["BFIS ID"])
          if service.present?
            apply_taxonomies(service, row)
          else
            puts "No service found for ID #{row["BFIS ID"]}"
          end
        end
      end
    end

    task :apply_bfis_directory_to_current => :environment do
      set_existing_taxonomies_as_bfis
    end

    def set_existing_taxonomies_as_bfis
      puts "Applying BFIS directory to existing taxonomies"
      Taxonomy.all.each do |taxonomy|
        taxonomy.skip_mongo_callbacks = true
        taxonomy.directories << Directory.where(name: "Family Information Service").first
      end
    end

    def apply_taxonomies(service, row)
      service.skip_mongo_callbacks = true
      row["Tags"].present? ? taxonomies_to_apply = eval(row["Tags"]) : taxonomies_to_apply = []
      taxonomies_to_apply << row["Category"]
      puts "applying  taxonomies: #{taxonomies_to_apply} to service #{service.name}"

      taxonomies_to_apply.each do |taxonomy_to_apply|
        taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(TAXONOMY_MAPPING[taxonomy_to_apply]) if TAXONOMY_MAPPING[taxonomy_to_apply].present?
        if taxonomy.present?
          taxonomy.directories << Directory.where(name: "Buckinghamshire Online Directory").first unless taxonomy.directories.include?(Directory.where(name: "Buckinghamshire Online Directory").first)
          service.taxonomies |= [taxonomy] if taxonomy.present?
        else
          puts "Taxonomy not found in mapping: #{taxonomy_to_apply}"
        end
      end
      puts "applied taxonomies #{service.taxonomies.inspect} to service #{service.name}"
      puts "failed to save service #{service.name}" unless service.save
    end
  end
end