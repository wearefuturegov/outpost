require_relative "boot"

require 'csv' # added by us previously

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Outpost
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # carried over from the previous config previous settings are the same
    config.active_model.i18n_customize_full_message = true
    
    # set time zone
    config.time_zone = 'London'

    # don't wrap error fields in a div, to avoid breaking radios and checkboxes
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| 
      "#{html_tag}".html_safe
    }

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get]
      end
    end

    config.action_mailer.default_url_options = { host: ENV["MAILER_HOST"] }

    config.action_mailer.delivery_method = :notify
    config.action_mailer.notify_settings = {
      api_key: ENV["NOTIFY_API_KEY"]
    }

    # Active Storage image handling 
    # Show svgs as images not files
    config.active_storage.content_types_to_serve_as_binary -= ['image/svg+xml']

    # remove unused tag objects after removing tagging
    ActsAsTaggableOn.remove_unused_tags = true
 
  end
end
