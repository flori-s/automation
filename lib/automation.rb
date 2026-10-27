# frozen_string_literal: true

require "automation/version"
require "automation/config"
require "automation/engine"

module Automation
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end

    def reset_config!
      @config = Config.new
    end

    def each_tenant(&block)
      config.each_tenant(&block)
    end

    def report_error(message, error = nil)
      config.report_error(message, error)
    end
  end
end
