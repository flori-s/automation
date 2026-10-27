# frozen_string_literal: true

module Automation
  class Executor
    MAX_ATTEMPTS = 5

    def self.call(job)
      new(job).call
    end

    def initialize(job)
      @job = job
    end

    def call
      return unless job.running?

      record = job.target
      rule = job.rule
      if record.nil? || rule.nil? || !rule.enabled? || skip?(rule, record)
        job.update!(status: "cancelled")
        return
      end

      context = Automation::Context.new(record: record, rule: rule, job: job)
      Automation::Action.dispatch(rule.action, context)
      job.update!(status: "completed", executed_at: Time.current, error_message: nil)
    rescue StandardError => e
      fail_job(e)
    end

    private

    attr_reader :job

    def skip?(rule, record)
      trigger = Automation::Trigger.for(rule.trigger)
      FieldMatch.matches?(record, rule.cancel_conditions) || !trigger.conditions_met?(record)
    end

    def fail_job(error)
      attempts = job.attempts.to_i + 1
      status = attempts >= MAX_ATTEMPTS ? "failed" : "pending"
      job.update!(
        status: status,
        attempts: attempts,
        error_message: error.message.to_s.truncate(10_000)
      )
      Automation.report_error("Automation job #{job.id} failed", error)
    end
  end
end
