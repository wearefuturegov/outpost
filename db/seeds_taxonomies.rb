module SeedsTaxonomies

  def self.create_default_taxonomies(taxonomies, parent_id = nil)
    taxonomies.each do |taxonomy|
        parent = Taxonomy.find_or_create_by!(name: taxonomy["name"], parent_id: parent_id)
        next unless taxonomy["children"]
    
        taxonomy["children"].each do |child|
          if child.is_a?(Hash)
              create_default_taxonomies([child], parent.id)
          else
              Taxonomy.find_or_create_by!(name: child, parent_id: parent.id)
          end
        end
    end
  end


  # create nested taxonomies - chance of subcategories being generated is different at each level
  def self.create_taxonomy(level = 0, parent_id = nil)
      return if level >= 4
      
      taxon = Taxonomy.create!({
          name: Faker::Lorem.words(number: rand(2...5)).join(' ').capitalize,
          parent_id: parent_id
      })
      
      case level
      when 0
          rand(2..10).times { create_taxonomy(level + 1, taxon.id) } if rand < 0.50
      when 1
          rand(3..15).times { create_taxonomy(level + 1, taxon.id) } if rand < 0.2
      when 2
          rand(1..3).times { create_taxonomy(level + 1, taxon.id) } if rand < 0.15
      end
  end
        
  def self.create_taxonomies
    5.times { create_taxonomy }
  end
end