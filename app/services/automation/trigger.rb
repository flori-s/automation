# frozen_string_literal: true

module Automation
  class Trigger
    def self.for(config)
      data = (config || {}).with_indifferent_access
      case data[:type]
      when "relative_date"
        Triggers::RelativeDate.new(data)
      else
        raise ArgumentError, I18n.t("automation.errors.unknown_trigger", type: data[:type])
      end
    end
  end
end
