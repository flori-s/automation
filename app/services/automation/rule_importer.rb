# frozen_string_literal: true

module Automation
  class RuleImporter
    def initialize(json)
      @json = json.is_a?(String) ? JSON.parse(json) : json
    end

    def process
      rule = Rule.where(key: data.fetch("key")).first_or_initialize
      rule.assign_attributes(attributes)
      rule.save!
      sync_targets(rule)
      rule
    end

    def self.export(rule)
      {
        "key" => rule.key,
        "name" => rule.name,
        "target_type" => rule.target_type,
        "enabled" => rule.enabled,
        "trigger" => rule.trigger,
        "action" => rule.action,
        "cancel_conditions" => rule.cancel_conditions
      }
    end

    private

    attr_reader :json

    def data
      @data ||= (json["automation_rule"] || json).stringify_keys
    end

    def attributes
      {
        name: data.fetch("name"),
        target_type: data.fetch("target_type"),
        enabled: data.fetch("enabled", true),
        trigger: data.fetch("trigger"),
        action: data.fetch("action"),
        cancel_conditions: data["cancel_conditions"] || {}
      }
    end

    def sync_targets(rule)
      return unless rule.enabled?

      klass = rule.target_type.safe_constantize
      return unless klass

      klass.find_each { |record| Automation::Scheduler.sync(record) }
    end
  end
end
