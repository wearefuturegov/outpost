instance = ENV["INSTANCE"]
instance ||= "default"
APP_CONFIG = YAML.load_file(Rails.root.join('config/app_config.yml'))[instance]