require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BusReservationSystem
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    
    config.load_defaults 7.0
    config.time_zone = "Asia/Kolkata"
    # config.assets.enabled = true 

    Rails.application.config.active_storage.queue = :inline
    # Rails.application.config.active_storage.queue = :sidekiq

    # Configuration for the application, engines, and railties goes here.

    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # config.eager_load_paths << Rails.root.join("extras")
  end
end
