# frozen_string_literal: true

module Automation
  class Context
    attr_reader :record, :rule, :job

    def initialize(record:, rule:, job:)
      @record = record
      @rule = rule
      @job = job
    end

    def params
      action = (rule.action || {}).with_indifferent_access
      action[:params] || {}
    end
  end
end
