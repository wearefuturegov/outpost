namespace :bod do
  namespace :directories do
    task :create => :environment do
      Puts "Creating directories..."
      Directory.create(name: 'Family Information Service', label: 'bfis')
      Directory.create(name: 'Buckinghamshire Online Directory', label: 'bod')
    end
  end
end