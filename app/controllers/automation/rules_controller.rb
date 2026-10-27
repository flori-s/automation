# frozen_string_literal: true

module Automation
  class RulesController < ApplicationController
    before_action { @automation_section = :rules }

    def index
      @automation_rules = Rule.order(:name)
    end

    def upload
      uploaded = params[:import_file]
      raise ArgumentError, I18n.t("automation.rules.no_file") if uploaded.blank?

      Automation::RuleImporter.new(JSON.parse(uploaded.read)).process
      redirect_to rules_path, notice: I18n.t("automation.rules.imported")
    rescue JSON::ParserError, ActiveRecord::RecordInvalid, ArgumentError, KeyError => e
      redirect_to rules_path, alert: e.message
    end

    def export
      rule = Rule.find(params[:id])
      send_data JSON.pretty_generate(Automation::RuleImporter.export(rule)),
                filename: "#{rule.key}.json",
                type: "application/json"
    end
  end
end
