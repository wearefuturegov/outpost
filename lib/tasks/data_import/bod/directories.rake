namespace :bod do
  namespace :directories do
    task :create => :environment do
      puts "Creating directories..."
      Directory.create(name: 'Family Information Service', label: 'bfis', scout_build_hook: '#', scout_url: 'https://directory.familyinfo.buckinghamshire.gov.uk/', is_public: true)
      Directory.create(name: 'Buckinghamshire Online Directory', label: 'bod', scout_build_hook: '#', scout_url: 'https://directory.buckinghamshire.gov.uk/', is_public: true)
    end
  end
end