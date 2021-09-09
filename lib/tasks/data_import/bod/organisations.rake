namespace :bod do
  namespace :organisations do
    task :trim => :environment do
      Organisation.all.where("name like '% '").or(Organisation.where("name like ' %'")).each do |org|
        org.skip_mongo_callbacks = true
        org.name.strip!
        unless org.save
          puts "Org #{org.name} failed to save: #{org.errors.messages}"
        end
      end
    end
  end
end