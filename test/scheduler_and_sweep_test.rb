# frozen_string_literal: true

require "test_helper"

class SchedulerAndSweepTest < ActiveSupport::TestCase
  def create_rule
    Automation::RuleImporter.new(
      "key" => "widget_expiry",
      "name" => "Widget expiry",
      "target_type" => "Widget",
      "enabled" => true,
      "trigger" => {
        "type" => "relative_date",
        "anchor" => "expires_on",
        "offset" => { "days" => -30 },
        "conditions" => { "active" => true }
      },
      "action" => {
        "type" => "call_service",
        "params" => { "service" => "WidgetReminder" }
      },
      "cancel_conditions" => { "active" => false }
    ).process
  end

  def jobs_for(widget)
    Automation::Job.where(target: widget)
  end

  test "schedules a job 30 days before the anchor date" do
    rule = create_rule
    expires_on = Date.current + 60

    widget = Widget.create!(expires_on: expires_on, active: true)
    job = jobs_for(widget).pending.first

    assert_equal 1, jobs_for(widget).pending.count
    expected = Time.zone.local((expires_on - 30).year, (expires_on - 30).month, (expires_on - 30).day)
    assert_equal expected, job.run_at
    assert_equal rule, job.rule
  end

  test "cancels the pending job when cancel conditions match" do
    create_rule
    widget = Widget.create!(expires_on: Date.current + 60, active: true)

    widget.update!(active: false)

    assert_empty jobs_for(widget).pending
    assert jobs_for(widget).cancelled.exists?
  end

  test "sweep calls the allow-listed service when the job is due" do
    create_rule
    widget = Widget.create!(expires_on: Date.current + 10, active: true)

    Automation::Sweep.call

    assert_equal [widget.id], WidgetReminder.calls
    assert jobs_for(widget).first.completed?
  end

  test "on_error is used instead of a hardcoded reporter" do
    errors = []
    Automation.configure { |config| config.on_error = ->(message, error) { errors << [message, error] } }
    Automation.report_error("boom", RuntimeError.new("nope"))

    assert_equal 1, errors.size
    assert_equal "boom", errors.first[0]
    assert_instance_of RuntimeError, errors.first[1]
  end
end
