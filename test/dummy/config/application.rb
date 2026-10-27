# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.secret_key_base = "x" * 128
    config.time_zone = "UTC"
    config.i18n.default_locale = :en
    config.active_record.migration_error = false
    config.active_record.maintain_test_schema = false
    config.paths["db/migrate"] << File.expand_path("../../../db/migrate", __dir__)
  end
end
