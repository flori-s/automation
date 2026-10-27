# frozen_string_literal: true

module Automation
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
