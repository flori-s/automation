# frozen_string_literal: true

Rails.application.config.to_prepare do
  # Allow-list host services that call_service actions may invoke:
  # Automation::Actions::CallService.allow("Identifications::ExpirationService", Identifications::ExpirationService)
end

Automation.configure do |config|
  # Multi-tenant (Apartment)
  # config.tenant_names = -> { CustomerTenant.all_tenants }
  # config.tenant_switch = ->(tenant, &block) { Apartment::Tenant.switch(tenant, &block) }
  # config.on_tenant_error = ->(error, tenant) { Rails.logger.error("Automation sweep for #{tenant} failed: #{error}") }

  # Error reporter (Rollbar, Sentry, …). Defaults to Rails.logger.
  # config.on_error = ->(message, error) { Rollbar.error(message, error) }
end
