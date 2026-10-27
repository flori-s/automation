# frozen_string_literal: true

module Automation
  class Scheduler
    def self.sync(record)
      new(record).sync
    end

    def self.cancel(record)
      Job.pending.where(target_type: record.class.name, target_id: record.id)
         .update_all(status: "cancelled", updated_at: Time.current)
    end

    def initialize(record)
      @record = record
    end

    def sync
      Rule.enabled.where(target_type: record.class.name).find_each do |rule|
        sync_rule(rule)
      end
    end

    private

    attr_reader :record

    def sync_rule(rule)
      trigger = Automation::Trigger.for(rule.trigger)
      if schedulable?(rule, trigger)
        upsert(rule, trigger)
      else
        cancel_rule(rule)
      end
    rescue StandardError => e
      Automation.report_error("Automation schedule failed for #{record.class.name} #{record.id} rule #{rule.id}", e)
    end

    def schedulable?(rule, trigger)
      return false if FieldMatch.matches?(record, rule.cancel_conditions)
      return false unless trigger.conditions_met?(record)

      anchor = trigger.anchor_date(record)
      anchor.present? && anchor >= Date.current && trigger.run_at(record).present?
    end

    def upsert(rule, trigger)
      run_at = trigger.run_at(record)
      key = trigger.idempotency_key(rule, record)
      cancel_other_pending(rule, key)

      job = Job.find_by(idempotency_key: key)
      if job.nil?
        Job.create!(
          rule: rule,
          target: record,
          run_at: run_at,
          status: "pending",
          idempotency_key: key
        )
      elsif job.pending?
        job.update!(run_at: run_at) if job.run_at.to_i != run_at.to_i
      elsif job.cancelled?
        job.update!(run_at: run_at, status: "pending", attempts: 0, error_message: nil)
      end
    end

    def cancel_rule(rule)
      Job.pending.where(rule: rule, target_type: record.class.name, target_id: record.id)
         .update_all(status: "cancelled", updated_at: Time.current)
    end

    def cancel_other_pending(rule, key)
      Job.pending.where(rule: rule, target_type: record.class.name, target_id: record.id)
         .where.not(idempotency_key: key)
         .update_all(status: "cancelled", updated_at: Time.current)
    end
  end
end
