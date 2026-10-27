# frozen_string_literal: true

module Automation
  module Automatable
    extend ActiveSupport::Concern

    included do
      after_commit :sync_automations, on: %i[create update]
      after_commit :cancel_automations, on: :destroy
    end

    private

    def sync_automations
      Automation::Scheduler.sync(self)
    rescue StandardError => e
      Automation.report_error("Automation sync failed for #{self.class.name} #{id}", e)
    end

    def cancel_automations
      Automation::Scheduler.cancel(self)
    rescue StandardError => e
      Automation.report_error("Automation cancel failed for #{self.class.name} #{id}", e)
    end
  end
end
