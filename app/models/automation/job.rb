# frozen_string_literal: true

module Automation
  class Job < ApplicationRecord
    self.table_name = "automation_jobs"

    belongs_to :rule, class_name: "Automation::Rule", foreign_key: :automation_rule_id, inverse_of: :jobs
    belongs_to :target, polymorphic: true, optional: true

    enum status: {
      pending: "pending",
      running: "running",
      completed: "completed",
      failed: "failed",
      cancelled: "cancelled"
    }

    validates :run_at, :target_type, :target_id, :idempotency_key, presence: true
    validates :idempotency_key, uniqueness: true

    scope :due, -> { pending.where("run_at <= ?", Time.current) }
  end
end
