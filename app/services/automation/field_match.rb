# frozen_string_literal: true

module Automation
  module FieldMatch
    module_function

    def matches?(record, conditions)
      pairs = (conditions || {}).with_indifferent_access
      return false if pairs.blank?

      pairs.all? { |field, expected| record.public_send(field) == expected }
    end
  end
end
