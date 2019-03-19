require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DemoWebApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # timezone
    config.time_zone = 'Asia/Tokyo'

    # runner 実行のために追加 (eager_load_paths は production環境で必要)
    config.paths.add 'lib', eager_load: true

    # sassを使用する
    config.sass.preferred_syntax = :sass
    config.sass.syntax = :sass
  end
end
