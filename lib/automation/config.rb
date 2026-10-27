# frozen_string_literal: true

module Automation
  class Config
    # Tenant names, or a callable that returns them.
    # Leave unset when the app has a single database.
    attr_accessor :tenant_names

    # Callable that runs a block inside a tenant: tenant_switch.call(name) { ... }
    attr_accessor :tenant_switch

    # Callable invoked when one tenant fails: on_tenant_error.call(error, tenant)
    # The sweep continues with the remaining tenants.
    attr_accessor :on_tenant_error

    # Callable invoked on runtime errors: on_error.call(message, error)
    attr_accessor :on_error

    def each_tenant
      names = resolve_tenant_names
      if names.empty?
        yield nil
        return
      end

      raise ArgumentError, "Automation tenant_switch is required when tenant_names is set" if tenant_switch.nil?

      names.each do |tenant|
        tenant_switch.call(tenant) { yield tenant }
      rescue StandardError => e
        report_tenant_error(e, tenant)
      end
    end

    def report_error(message, error = nil)
      if on_error
        on_error.call(message, error)
      elsif defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
        detail = error ? "#{error.class}: #{error.message}" : nil
        Rails.logger.error([message, detail].compact.join(" "))
      end
    end

    private

    def resolve_tenant_names
      names = tenant_names.respond_to?(:call) ? tenant_names.call : tenant_names
      Array(names).compact
    end

    def report_tenant_error(error, tenant)
      if on_tenant_error
        on_tenant_error.call(error, tenant)
      else
        report_error("Automation sweep for #{tenant} failed", error)
      end
    end
  end
end
