namespace :taxonomy do

  task :create_categories_from_old_db => [ :environment ] do
    csv_file = File.open('lib/seeds/bucksfis_geo.csv', "r:ISO-8859-1")
    bucks_csv = CSV.parse(csv_file, headers: true)
    tree = {}

    bucks_csv.each.with_index do |row, line|
      #puts "Processing line (taxonomy build): #{line} of #{bucks_csv.size}"

      lines = []
      lines = lines.concat(row['familychannel'].split("\n")) if row['familychannel'].present?
      lines = lines.concat(row['parentchannel'].split("\n")) if row['parentchannel'].present?
      lines = lines.concat(row['youthchannel'].split("\n")) if row['youthchannel'].present?

      if lines.present?
        lines.each do |line|
          parent = nil

          categories = line.split(' > ')
          categories.delete("Family Information")
          categories.each do |category|
            taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by!(name: category, parent_id: parent&.id)
            parent = taxonomy
          end
        end
      end

    end
  end

  task :list_children => [ :environment ] do
    top_level_taxonomy = Taxonomy.where(name: 'Taxonomy').first
    list_children(top_level_taxonomy)
  end

  task :map_to_new_taxonomy => [ :environment ] do
    csv_file = File.open('lib/seeds/taxonomy_mapping.csv', "r:ISO-8859-1")
    taxonomy_mapping_csv = CSV.parse(csv_file, headers: true)
    taxonomy_mapping_csv.each do |row|
      old_taxonomy = nil
      new_taxonomy = nil
      additional_new_taxonomy = nil

      next unless row["Old taxonomy"].present?

      # paths
      old_path = row["Old taxonomy"].split(" > ").map(&:strip)
      puts "Old path: #{old_path}"

      new_path = row["New taxonomy"].split(" > ").map(&:strip) if row["New taxonomy"].present?
      puts "New path: #{new_path}" if row["New taxonomy"].present?

      additional_new_path = row["Additional new taxonomy"].split(" > ").map(&:strip) if row["Additional new taxonomy"].present?
      puts "Additional new path: #{additional_new_path}" if row["Additional new taxonomy"].present?

      # taxonomies
      old_taxonomy = Taxonomy.find_by_path(old_path)
      puts "Old taxa: #{old_taxonomy.name}" if old_taxonomy.present?

      new_taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(new_path) if new_path.present?
      puts "New taxa: #{new_taxonomy.name}" if new_taxonomy.present?

      additional_new_taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(additional_new_path) if additional_new_path.present?
      puts "Additional new taxa: #{additional_new_taxonomy.name}" if additional_new_taxonomy.present?

      if (new_taxonomy.present? && old_taxonomy.present?)
        new_taxonomy.services |= old_taxonomy.services
        new_taxonomy.skip_mongo_callbacks = true
        new_taxonomy.save
        puts "New taxa service count: #{new_taxonomy.services.count}"
      end

      if (additional_new_taxonomy.present? && old_taxonomy.present?)
        additional_new_taxonomy.services |= old_taxonomy.services
        additional_new_taxonomy.skip_mongo_callbacks = true
        additional_new_taxonomy.save
        puts "Additional new taxa service count: #{additional_new_taxonomy.services.count}"
      end
    end
  end

  # Useful if need to assign taxonomies without creating all servics again (main seed)
  task :assign_services_from_oo_csv => [ :environment ] do
    csv_file = File.open('lib/seeds/bucksfis_geo.csv', "r:utf-8")
    bucks_csv = CSV.parse(csv_file, headers: true)

    bucks_csv.each.with_index do |row, csv_line|

      puts "Processing service taxonomy): #{csv_line} of #{bucks_csv.size} for service #{row["title"]}"

      service = Service.where(name: row['title']).first

      if service.present?
        unless row['familychannel'] == nil
          lines = row['familychannel'].split("\n")
          lines.each do |line|
            categories = line.split(' > ')
            categories.delete("Family Information")

            taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(categories)
            service.taxonomies |= [taxonomy]
          end
        end

        unless row['parentchannel'] == nil
          lines = row['parentchannel'].split("\n")
          lines.each do |line|
            categories = line.split(' > ')
            taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(categories)
            service.taxonomies |= [taxonomy]
          end
        end

        unless row['youthchannel'] == nil
          lines = row['youthchannel'].split("\n")
          lines.each do |line|
            categories = line.split(' > ')
            taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(categories)
            service.taxonomies |= [taxonomy]
          end
        end

        unless row['childrenscentrechannel'] == nil
          lines = row['childrenscentrechannel'].split("\n")
          lines.each do |line|
            categories = line.split(' > ')
            taxonomy = Taxonomy.create_with(skip_mongo_callbacks: true).find_or_create_by_path(categories)
            service.taxonomies |= [taxonomy]
          end
        end
        service.skip_mongo_callbacks = true
        unless service.save
          puts "Failed to save service #{service.id}"
        end
      end
    end
  end

  # Use to completely reset taxonomies, using csvs to map etc
  task :full_reset => [ :environment ] do
    Taxonomy.destroy_all
    ServiceTaxonomy.destroy_all
    Rake::Task['taxonomy:create_categories_from_old_db'].invoke
    Rake::Task['taxonomy:assign_services_from_oo_csv'].invoke
    Rake::Task['taxonomy:map_to_new_taxonomy'].invoke
    Rake::Task['taxonomy:delete_old_taxonomies'].invoke
    Rake::Task['taxonomy:populate_parents'].invoke
    Rake::Task['taxonomy:reset_counters'].invoke
  end


  task :delete_old_taxonomies => [ :environment ] do
    csv_file = File.open('lib/seeds/taxonomy_mapping.csv', "r:ISO-8859-1")
    taxonomy_mapping_csv = CSV.parse(csv_file, headers: true)
    taxonomy_mapping_csv.each do |row|

      next unless row["Old taxonomy"].present?
      next if  row["Old taxonomy"] == row["New taxonomy"]

      old_path = row["Old taxonomy"].split(" > ").map(&:strip)
      old_taxonomy = Taxonomy.find_by_path(old_path)
      if old_taxonomy.present?
        old_taxonomy.service_taxonomies.destroy_all
        old_taxonomy.destroy!
        puts "deleted #{old_taxonomy.name}"
      end
    end
  end

  task :populate_parents => [ :environment ] do
    Service.includes(:taxonomies).each do |s|
      s.skip_mongo_callbacks = true
      s.save
    end
  end

  task :remove_all_needs_met => [ :environment ] do
    all_needs_met_taxonomy = SendNeed.where(name: "All needs met").first
    all_needs_met_taxonomy.destroy! if all_needs_met_taxonomy.present?
  end

  task :lock_top_level => [ :environment ] do
    Taxonomy.roots.each do |t|
      t.locked = true
      t.skip_mongo_callbacks = true
      unless t.save
          puts "Taxonomy #{t} failed to save: #{t.errors.messages}"
      end
    end
  end

  task :reset_counters => :environment  do
    Taxonomy.find_each do |taxonomy|
      Taxonomy.reset_counters(taxonomy.id, :services)
    end
  end

end

def list_children(taxonomy)
  level = ""
  #level_depth = 0
  if taxonomy&.parent&.parent&.parent&.parent&.parent.present?
    level += ";;;;;"
    level_depth = 5
  elsif taxonomy&.parent&.parent&.parent&.parent.present?
    level_depth = 4
    level += ";;;;"
  elsif taxonomy&.parent&.parent&.parent.present?
    level_depth = 3
    level += ";;;"
  elsif taxonomy&.parent&.parent.present?
    level_depth = 2
    level += ";;"
  elsif taxonomy&.parent.present?
    level_depth = 1
    level += ";"
  end
  # puts "#{level} #{taxonomy.name.tr(',', ' ')}"
  puts "#{level} #{taxonomy.name}"
  # if prev_depth != level_depth
  #   puts "/n"
  # end
  taxonomy.children.each do |child_taxonomy|
    list_children(child_taxonomy)
  end
end