#!/bin/sh
# Xcode Cloud runs this before every xcodebuild action.
#
# An archive without SENTRY_DSN would ship with crash reports off and say so
# nowhere: the app quietly skips Sentry when its DSN is empty (#222). Stop the
# archive instead, so a missing DSN can't reach the App Store unnoticed. Builds
# and tests (no archive) still run without it.

set -e

if [ "${CI_XCODEBUILD_ACTION}" = "archive" ] && [ -z "${SENTRY_DSN}" ]; then
  echo "error: SENTRY_DSN is not set on this Xcode Cloud workflow, so this archive would ship without crash reports. Add it under Environment as a secret, then build again. See docs/SENTRY.md."
  exit 1
fi
