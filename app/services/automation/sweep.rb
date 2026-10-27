# frozen_string_literal: true

module Automation
  class Sweep
    STALE_AFTER = 1.hour

    def self.call
      new.call
    end

    def call
      release_stale_claims
      Job.due.find_each { |job| claim_and_run(job) }
    end

    private

    def release_stale_claims
      Job.running.where("updated_at < ?", STALE_AFTER.ago)
         .update_all(status: "pending", updated_at: Time.current)
    end

    def claim_and_run(job)
      claimed = Job.where(id: job.id, status: "pending").update_all(
        status: "running",
        updated_at: Time.current
      )
      return unless claimed == 1

      Automation::Executor.call(job.reload)
    rescue StandardError => e
      Automation.report_error("Automation sweep failed for job #{job.id}", e)
    end
  end
end
