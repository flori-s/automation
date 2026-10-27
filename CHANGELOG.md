# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-10-27

### Added

- Mountable Rails engine (`Automation::Engine`) with jobs and rules dashboard at `/automation`
- JSON rules with `relative_date` triggers and `call_service` actions
- `Automation::Automatable` for host models (schedule on create/update, cancel on destroy)
- DB-backed `automation_jobs` queue with `rake automation:sweep`
- Optional Apartment-style tenancy via `tenant_names` / `tenant_switch` / `on_tenant_error`
- Pluggable `on_error` reporter (defaults to `Rails.logger`)
- Rule import/export JSON and `rails generate automation:install`
