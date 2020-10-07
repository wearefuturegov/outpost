task :reset_taxonomy_counters => :environment  do
  Taxonomy.find_each do |taxonomy|
    Taxonomy.reset_counters(taxonomy.id, :services)
  end
end