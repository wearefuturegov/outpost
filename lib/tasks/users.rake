namespace :users do

  task :create_users_from_file => :environment do

    #Create bucks and fg users
    user_logins_yaml = Rails.root.join('lib', 'seeds', 'user_logins.yml')
    user_logins = YAML::load_file(user_logins_yaml)
    user_logins.each do |user_login|
      user_login["admin_users"] = true
      user_login["admin_ofsted"] = true
      unless (User.where(email: user_login["email"]).size > 0)
        user = User.new(user_login)
        user.password = "A9b#{SecureRandom.hex(8)}1yZ"
        unless user.save
          puts "User #{user_login["email"]} failed to save: #{user.errors.messages}"
        end
      end
    end
  end
end