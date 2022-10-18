namespace :import do
  desc 'Create users from YAML file'
  task :users => :environment do

    user_logins_yaml = Rails.root.join('lib', 'seeds', 'user_logins.yml')
    user_logins = YAML::load_file(user_logins_yaml)
    user_logins.each do |user_login|
      user_login["admin_users"] = true
      user_login["admin_ofsted"] = true
      unless User.find_by(email: user_login["email"])
        user = User.new(user_login)
        user.password = "A9b#{SecureRandom.hex(8)}1yZ" unless user.password
        unless user.save
          puts "User #{user_login["email"]} failed to save: #{user.errors.messages}"
        end
      end
    end
  end

end
