# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"

ActiveRecord::Migrator.migrations_paths = [
  File.expand_path("../test/dummy/db/migrate", __dir__),
  File.expand_path("../db/migrate", __dir__)
]
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.connection.migration_context.migrate

ActiveRecord::Schema.define do
  create_table :widgets, force: true do |t|
    t.date :expires_on
    t.boolean :active, null: false, default: true
    t.timestamps
  end
end

require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: 1)

    setup do
      Automation.reset_config!
      Automation::Action.register("call_service", Automation::Actions::CallService)
      Automation::Actions::CallService.allowed.clear
      Automation::Actions::CallService.allow("WidgetReminder", WidgetReminder)
      WidgetReminder.reset!
      Automation::Job.delete_all
      Automation::Rule.delete_all
      Widget.delete_all
    end
  end
end
