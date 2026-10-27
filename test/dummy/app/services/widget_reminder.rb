# frozen_string_literal: true

class WidgetReminder
  class << self
    attr_accessor :calls

    def call(record)
      self.calls ||= []
      calls << record.id
    end

    def reset!
      self.calls = []
    end
  end
end
