namespace :taxonomy do

  task :create_categories_from_old_db => [ :environment ] do
    top_level_taxonomy = Taxonomy.find_or_create_by(name: 'Categories')
    csv_file = File.open('lib/seeds/bucksfis geo.csv', "r:ISO-8859-1")
    bucks_csv = CSV.parse(csv_file, headers: true)
    tree = {}

    bucks_csv.each.with_index do |row, line|
      puts "Processing line (taxonomy build): #{line} of #{bucks_csv.size}"

      if row['familychannel'].present?
        lines = row['familychannel'].split("\n")
      elsif row['parentchannel'].present?
        lines = row['parentchannel'].split("\n")
      elsif row['youthchannel'].present?
        lines = row['youthchannel'].split("\n")
      end

      if lines.present?
        lines.each do |line|
          parent = top_level_taxonomy

          categories = line.split(' > ')
          categories.delete("Family Information")
          categories.each do |category|
            taxonomy = Taxonomy.find_or_create_by(name: category, parent_id: parent.id)
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
      next unless row["Old taxonomy"].present?

      # paths
      old_path = row["Old taxonomy"].split(" > ").unshift("Categories")
      puts "Old path: #{old_path}"
      new_path = row["New taxonomy"].split(" > ").unshift("Categories").map(&:strip) if row["New taxonomy"].present?
      puts "New path: #{new_path}" if row["New taxonomy"].present?
      additional_new_path = row["Additional new taxonomy"].split(" > ").unshift("Categories").map(&:strip) if row["Additional new taxonomy"].present?
      puts "Additional new path: #{additional_new_path}" if row["Additional new taxonomy"].present?

      # taxonomies
      old_taxonomy = Taxonomy.find_by_path(old_path)
      puts "Old taxa: #{old_taxonomy.name}" if old_taxonomy.present?
      new_taxonomy = Taxonomy.find_or_create_by_path(new_path) if new_path.present?
      puts "New taxa: #{new_taxonomy.name}" if new_taxonomy.present?
      additional_new_taxonomy = Taxonomy.find_or_create_by_path(additional_new_path) if additional_new_path.present?
      puts "Additional new taxa: #{additional_new_taxonomy.name}" if additional_new_taxonomy.present?

      new_taxonomy.services = old_taxonomy.services if (new_taxonomy.present? && old_taxonomy.present?)
      new_taxonomy.save if new_taxonomy.present?
      puts "New taxa service count: #{new_taxonomy.services.count}" if new_taxonomy.present?

      additional_new_taxonomy.services = old_taxonomy.services if (additional_new_taxonomy.present? && old_taxonomy.present?)
      additional_new_taxonomy.save if additional_new_taxonomy.present?
      puts "Additional new taxa service count: #{additional_new_taxonomy.services.count}" if additional_new_taxonomy.present?
    end
  end

  task :delete_old_taxonomies => [ :environment ] do
    csv_file = File.open('lib/seeds/taxonomy_mapping.csv', "r:ISO-8859-1")
    taxonomy_mapping_csv = CSV.parse(csv_file, headers: true)
    taxonomy_mapping_csv.each do |row|
      next unless row["Old taxonomy"].present?
      old_path = row["Old taxonomy"].split(" > ").unshift("Categories")
      old_taxonomy = Taxonomy.find_by_path(old_path)
      old_taxonomy.destroy! if old_taxonomy.present?
      puts "deleted #{old_taxonomy.name}" if old_taxonomy.present?
    end
  end

  task :populate_parents => [ :environment ] do
    Service.includes(:taxonomies).each do |s|
      s.skip_mongo_callbacks = true
      s.save
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