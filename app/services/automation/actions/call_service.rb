# frozen_string_literal: true

module Automation
  module Actions
    class CallService
      class NotAllowed < StandardError; end

      def self.allow(name, klass)
        allowed[name.to_s] = klass
      end

      def self.allowed
        @allowed ||= {}
      end

      def self.call(context)
        name = context.params[:service].to_s
        klass = allowed[name]
        raise NotAllowed, name if klass.nil? || !klass.respond_to?(:call)

        klass.call(context.record)
      end
    end
  end
end
