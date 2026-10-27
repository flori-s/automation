# frozen_string_literal: true

require "rails/generators"

module Automation
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_initializer
        template "initializer.rb", "config/initializers/automation.rb"
      end

      def mount_engine
        route 'mount Automation::Engine => "/automation"'
      end

      def show_readme
        say <<~MSG

          Automation installed.

          Next:
            1. rails automation:install:migrations && rails db:migrate
            2. Review config/initializers/automation.rb
            3. include Automation::Automatable on models you want scheduled
            4. Schedule: * * * * * cd /app && bin/rails automation:sweep

        MSG
      end
    end
  end
end
