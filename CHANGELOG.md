# Changelog

## v1.1.0

Maintenance-aware update release.

### Added
- Maintenance flag integration (`MAINT_FLAG`)
- API availability validation after container restart
- Safe state update only if Node API is reachable
- Explicit failure path when API does not recover

### Improved
- More deterministic post-restart validation flow
- Safer production behavior during controlled updates

## v1.0.0
- First public stable release
- Production-proven GeoIP / GeoSite updater
- systemd + Docker integration
- Telegram notifications
- State-based release tracking
- Safe temporary directory handling
- Failure handling with alerting
