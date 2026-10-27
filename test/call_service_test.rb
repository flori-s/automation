# frozen_string_literal: true

require "ostruct"
require "test_helper"

class CallServiceTest < ActiveSupport::TestCase
  test "calls an allowed service with the record" do
    record = Widget.create!(expires_on: Date.current + 60, active: true)
    rule = OpenStruct.new(action: { "type" => "call_service", "params" => { "service" => "WidgetReminder" } })
    context = Automation::Context.new(record: record, rule: rule, job: nil)

    Automation::Actions::CallService.call(context)

    assert_equal [record.id], WidgetReminder.calls
  end

  test "rejects services that are not allow-listed" do
    record = Widget.create!(expires_on: Date.current + 60, active: true)
    rule = OpenStruct.new(action: { "type" => "call_service", "params" => { "service" => "UnknownService" } })
    context = Automation::Context.new(record: record, rule: rule, job: nil)

    assert_raises(Automation::Actions::CallService::NotAllowed) do
      Automation::Actions::CallService.call(context)
    end
  end
end
