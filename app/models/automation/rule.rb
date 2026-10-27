# frozen_string_literal: true

module Automation
  class Rule < ApplicationRecord
    self.table_name = "automation_rules"

    has_many :jobs, class_name: "Automation::Job", foreign_key: :automation_rule_id, dependent: :restrict_with_error,
                    inverse_of: :rule

    scope :enabled, -> { where(enabled: true) }

    validates :name, :target_type, :key, presence: true
    validates :key, uniqueness: true
    validate :trigger_and_action_have_type

    private

    def trigger_and_action_have_type
      errors.add(:trigger, I18n.t("automation.errors.missing_type")) unless config_type?(trigger)
      errors.add(:action, I18n.t("automation.errors.missing_type")) unless config_type?(action)
    end

    def config_type?(value)
      value.is_a?(Hash) && value.with_indifferent_access[:type].present?
    end
  end
end
