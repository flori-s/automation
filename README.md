# Automation

Rails engine gem for **time-based automation rules** — JSON rules, relative-date triggers, a DB-backed job sweep (so you don’t need per-rule Delayed Job / Sidekiq scheduling), allow-listed host services, and an ops dashboard.

Requires **Ruby >= 3.0** and **Rails >= 6.1**.

## Install

```ruby
# Gemfile
gem "automation", github: "flori-s/automation"
```

```bash
bundle install
rails generate automation:install
rails automation:install:migrations
rails db:migrate
```

Mount (also added by the installer):

```ruby
# config/routes.rb
mount Automation::Engine => "/automation"
```

Opt a model in:

```ruby
class Identification < ApplicationRecord
  include Automation::Automatable
end
```

Allow the host service a rule may call:

```ruby
# config/initializers/automation.rb
Rails.application.config.to_prepare do
  Automation::Actions::CallService.allow(
    "Identifications::ExpirationService",
    Identifications::ExpirationService
  )
end

Automation.configure do |config|
  # Optional multi-tenant (Apartment)
  # config.tenant_names = -> { CustomerTenant.all_tenants }
  # config.tenant_switch = ->(tenant, &block) { Apartment::Tenant.switch(tenant, &block) }
  # config.on_tenant_error = ->(error, tenant) { Rails.logger.error(error) }

  # Optional error reporter (Rollbar, Sentry, …)
  # config.on_error = ->(message, error) { Rollbar.error(message, error) }
end
```

Schedule one cron entry:

```cron
* * * * * cd /app && bin/rails automation:sweep
```

## Rule JSON

```json
{
  "key": "identification_expiry",
  "name": "Identification expiry",
  "target_type": "Identification",
  "enabled": true,
  "trigger": {
    "type": "relative_date",
    "anchor": "expires_on",
    "offset": { "days": -30 },
    "conditions": { "active": true }
  },
  "action": {
    "type": "call_service",
    "params": { "service": "Identifications::ExpirationService" }
  },
  "cancel_conditions": { "active": false }
}
```

Import from the rules dashboard or:

```ruby
Automation::RuleImporter.new(JSON.parse(File.read("rule.json"))).process
```
