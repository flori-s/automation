# frozen_string_literal: true

module Automation
  module Triggers
    class RelativeDate
      def initialize(config)
        @config = config.with_indifferent_access
      end

      def conditions_met?(record)
        pairs = (config[:conditions] || {}).with_indifferent_access
        return true if pairs.blank?

        pairs.all? { |field, expected| record.public_send(field) == expected }
      end

      def anchor_date(record)
        value = record.public_send(config.fetch(:anchor))
        return if value.blank?

        value.to_date
      end

      def run_at(record)
        date = anchor_date(record)
        return if date.blank?

        target = date + offset_days
        Time.zone.local(target.year, target.month, target.day)
      end

      def idempotency_key(rule, record)
        date = anchor_date(record)
        return if date.blank?

        stamp = Time.zone.local(date.year, date.month, date.day).to_i
        "#{rule.id}:#{record.class.name}:#{record.id}:#{stamp}"
      end

      private

      attr_reader :config

      def offset_days
        (config.dig(:offset, :days) || 0).to_i
      end
    end
  end
end
