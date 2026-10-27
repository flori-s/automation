# frozen_string_literal: true

namespace :automation do
  desc "Run due automation jobs, once per configured tenant"
  task sweep: :environment do
    Automation.each_tenant do
      Automation::Sweep.call
    end
  end
end
