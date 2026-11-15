## Summary
<!-- What does this change and why? -->

Closes #

## Checklist
- [ ] Uses design `Tokens` only (no hardcoded colors/sizes); works in light + dark
- [ ] UI strings in English
- [ ] No new networking or analytics, and nothing from HealthKit in any Sentry event, breadcrumb or count
- [ ] Builds (`xcodebuild … build`) after `xcodegen generate`
- [ ] Verified on simulator (and device, if HealthKit/notifications/icon are involved)
- [ ] Updated docs / CHANGELOG if relevant
