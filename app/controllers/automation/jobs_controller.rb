# frozen_string_literal: true

module Automation
  class JobsController < ApplicationController
    before_action { @automation_section = :jobs }

    PER_PAGE = 25
    STATUSES = Job.statuses.keys.freeze

    helper_method :automation_job_statuses, :automation_job_status_label

    def index
      @status = STATUSES.include?(params[:status]) ? params[:status] : "pending"
      scope = Job.includes(:rule).where(status: @status).order(order_for(@status))
      @total_count = scope.count
      @total_pages = [(@total_count / PER_PAGE.to_f).ceil, 1].max
      @page = params[:page].to_i
      @page = 1 if @page < 1
      @page = @total_pages if @page > @total_pages
      @automation_jobs = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    end

    private

    def automation_job_statuses
      STATUSES
    end

    def automation_job_status_label(status)
      I18n.t("automation.jobs.statuses.#{status}")
    end

    def order_for(status)
      %w[pending running].include?(status) ? { run_at: :asc } : { updated_at: :desc }
    end
  end
end
