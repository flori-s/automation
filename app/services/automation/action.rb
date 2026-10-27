# frozen_string_literal: true

module Automation
  class Action
    class UnknownAction < StandardError; end

    def self.register(type, handler)
      registry[type.to_s] = handler
    end

    def self.dispatch(config, context)
      type = (config || {}).with_indifferent_access[:type]
      handler = registry[type.to_s]
      raise UnknownAction, type.to_s if handler.nil?

      handler.call(context)
    end

    def self.registry
      @registry ||= {}
    end
  end
end
