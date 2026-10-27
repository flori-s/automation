# frozen_string_literal: true

module Automation
  class Engine < ::Rails::Engine
    isolate_namespace Automation

    initializer "automation.append_migrations" do |app|
      unless app.root.to_s.match?(root.to_s)
        migration_path = root.join("db/migrate").to_s
        app.config.paths["db/migrate"] << migration_path unless app.config.paths["db/migrate"].include?(migration_path)
      end
    end

    initializer "automation.assets.precompile" do |app|
      if app.config.respond_to?(:assets) && app.config.assets
        app.config.assets.precompile += %w[automation_manifest.js automation/application.css automation/application.js]
      end
    end

    initializer "automation.actions" do
      config.to_prepare do
        Automation::Action.register("call_service", Automation::Actions::CallService)
      end
    end
  end
end
