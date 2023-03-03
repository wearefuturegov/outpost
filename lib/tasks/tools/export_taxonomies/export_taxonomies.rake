namespace :export do
  desc 'export taxonomies from the database to a csv file'
  task :taxonomies, [:file_path] => :environment do |t, args|
    args.with_defaults(file_path: Rails.root.join('lib', 'output', 'taxonomies.csv'))
    HEADERS = [
      'id',
      'parent_id',
      'sort_order'
    ]

    class Hash
      def flatten_nested; flat_map{|k, v| [k, *v.flatten_nested]} end
    end

    CSV.open(args.file_path, "wb", :headers => HEADERS, :write_headers => true) do |csv|
      Taxonomy.hash_tree.flatten_nested.map do |c| 
        csv << [c.id, c.parent_id, c.sort_order, *[nil]*c.depth, c.name]
      end
    end
  end
end