# frozen_string_literal: true

require "test_helper"

class RuleImporterTest < ActiveSupport::TestCase
  def sample_json(overrides = {})
    {
      "key" => "sample_rule",
      "name" => "Sample rule",
      "target_type" => "NotAModel",
      "enabled" => true,
      "trigger" => {
        "type" => "relative_date",
        "anchor" => "expires_on",
        "offset" => { "days" => -30 }
      },
      "action" => {
        "type" => "call_service",
        "params" => { "service" => "WidgetReminder" }
      },
      "cancel_conditions" => {}
    }.merge(overrides)
  end

  test "creates a rule from json" do
    rule = Automation::RuleImporter.new(sample_json).process

    assert rule.persisted?
    assert_equal "sample_rule", rule.key
    assert_equal(-30, rule.trigger.with_indifferent_access.dig("offset", "days"))
    assert_equal "WidgetReminder", rule.action.with_indifferent_access.dig("params", "service")
  end

  test "updates the same rule when imported again" do
    Automation::RuleImporter.new(sample_json).process
    updated = sample_json.merge(
      "name" => "Sample rule renamed",
      "trigger" => sample_json["trigger"].merge("offset" => { "days" => -14 })
    )

    assert_no_difference -> { Automation::Rule.count } do
      Automation::RuleImporter.new(updated).process
    end

    rule = Automation::Rule.find_by!(key: "sample_rule")
    assert_equal "Sample rule renamed", rule.name
    assert_equal(-14, rule.trigger.with_indifferent_access.dig("offset", "days"))
  end
end
