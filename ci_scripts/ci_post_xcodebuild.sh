#!/bin/sh
# Xcode Cloud runs this after every xcodebuild action.
#
# After an archive, first check the DSN the app was actually built with, then
# upload its dSYMs to Sentry so crash reports arrive symbolicated (#222). Needs SENTRY_AUTH_TOKEN (a secret) on the workflow; the
# token never goes in the repo. Without it, or if the upload fails, the build
# still goes on with a warning: the release is fine, only its stack traces are
# unreadable.

set -e

[ "${CI_XCODEBUILD_ACTION}" = "archive" ] || exit 0

# The check that counts: SentryDSN as the archived app's Info.plist holds it.
# ci_pre_xcodebuild.sh checks the inputs; this catches a DSN lost anywhere
# between the secret and the binary. A failing post-build script fails the
# build, so the archive never reaches TestFlight.
PLIST="${CI_ARCHIVE_PATH}/Products/Applications/Walkful.app/Info.plist"
BUILT_DSN="$(plutil -extract SentryDSN raw "$PLIST" 2>/dev/null || true)"
case "$BUILT_DSN" in
  https://*@*/*) echo "ci_post_xcodebuild: the archived app has a Sentry DSN" ;;
  *) echo "error: the archived app's SentryDSN is missing or malformed (read from $PLIST), so it would ship without crash reports. See docs/SENTRY.md."; exit 1 ;;
esac

if [ -z "${SENTRY_AUTH_TOKEN}" ]; then
  echo "warning: SENTRY_AUTH_TOKEN is not set, so the dSYMs were not uploaded to Sentry. See docs/SENTRY.md."
  exit 0
fi

# sentry-cli, pinned and checked against the release's published SHA-256.
CLI_VERSION="3.8.2"
CLI_SHA256="2d1b118fa46960ba5e8e0cca9a6e197366905776a0ddc5a89c7d05a3908b77db"
CLI="${CI_DERIVED_DATA_PATH:-/tmp}/sentry-cli"

if ! curl -sSfL -o "$CLI" "https://github.com/getsentry/sentry-cli/releases/download/${CLI_VERSION}/sentry-cli-Darwin-universal"; then
  echo "warning: could not download sentry-cli ${CLI_VERSION}; dSYMs not uploaded."
  exit 0
fi
if ! echo "${CLI_SHA256}  ${CLI}" | shasum -a 256 -c - >/dev/null; then
  echo "warning: sentry-cli checksum mismatch; dSYMs not uploaded."
  rm -f "$CLI"
  exit 0
fi
chmod +x "$CLI"

if "$CLI" debug-files upload \
    --org "${SENTRY_ORG:-iamjarl}" \
    --project "${SENTRY_PROJECT:-walkful}" \
    "${CI_ARCHIVE_PATH}/dSYMs"; then
  echo "ci_post_xcodebuild: dSYMs uploaded to Sentry"
else
  echo "warning: the dSYM upload to Sentry failed; crash reports from this build will be unsymbolicated."
fi
