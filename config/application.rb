# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Heliotropium
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # I'm going to set the timezone now, way too late, 2024-01-11 because
    # rufus-scheduler is supposed to be kicking off at midnight but that could be 8:00PM local time
    # which is annoying. It's been fine, but now we need to coordinate with automatic
    # kbart generation on fulcrum so time matters. See HELIO-4531.
    # Hopefully this will fix when the scheduler actually runs AssembleMarcFiles.run
    config.time_zone = 'Eastern Time (US & Canada)'

    config.generators do |g|
      g.stylesheets         false
      g.assets              false
      g.scaffold_stylesheet false
      g.fixture             false
      g.controller_specs    false
      g.view_specs          false
      g.routing_specs       false
      g.helper              false
      g.javascripts         false
      g.pretend             true
    end
  end
end
