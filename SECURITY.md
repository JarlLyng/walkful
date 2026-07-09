# Security Policy

## Reporting a vulnerability

If you've found a security issue in Walkful, please **don't open a public issue**. Email me directly:

**jarl@iamjarl.com**

Please include:
- A description of the vulnerability
- Steps to reproduce
- The affected version (App Store version or commit SHA)
- Your contact info if you'd like credit when it's fixed

I'll respond within 7 days. For confirmed issues, I'll work on a patch and ship it as quickly as the App Store review process allows (typically 1–3 days for review, plus development time).

## Scope

In scope:
- Walkful iOS app code
- The marketing site at `walkful.iamjarl.com`

Out of scope:
- Apple platform vulnerabilities — report to Apple Product Security
- Issues in forks of this repo

## What Walkful does and doesn't handle

Walkful is a single-purpose walking app with a deliberately small attack surface:

- **No backend.** No server, no database, no API endpoints. All data stays on the device.
- **No accounts.** No sign-up, no authentication, no password storage.
- **HealthKit is read on-device only.** Walkful reads step/activity data from HealthKit to show your progress; nothing is uploaded or sent off-device.
- **No tracking.** No analytics in the app. The marketing website uses aggregate, cookieless analytics only.
- **Payments via Apple.** The one-time Pro unlock goes through StoreKit / Apple; the app stores no card or payment data.

If you find a way to break any of those guarantees, I want to know.

## Past advisories

None to date.
