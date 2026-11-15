#!/bin/sh
# Xcode Cloud runs this before every xcodebuild action.
#
# An archive without SENTRY_DSN would ship with crash reports off and say so
# nowhere: the app quietly skips Sentry when its DSN is empty (#222). Stop the
# archive instead, so a missing DSN can't reach the App Store unnoticed. Builds
# and tests (no archive) still run without it.

set -e

[ "${CI_XCODEBUILD_ACTION}" = "archive" ] || exit 0

if [ -z "${SENTRY_DSN}" ]; then
  echo "error: SENTRY_DSN is not set on this Xcode Cloud workflow, so this archive would ship without crash reports. Add it under Environment as a secret, then build again. See docs/SENTRY.md."
  exit 1
fi

# A malformed DSN fails as quietly as a missing one, so check its shape too.
case "${SENTRY_DSN}" in
  https://*@*) ;;
  *) echo "error: SENTRY_DSN doesn't look like a DSN (https://<key>@<host>/<project>), so this archive would ship without crash reports. See docs/SENTRY.md."; exit 1 ;;
esac

# And the value the build will actually read: an xcconfig takes "//" as a
# comment, which is why ci_post_clone.sh writes the slashes as $(SLASH).
if ! grep -q '^SENTRY_DSN = https:$(SLASH)$(SLASH).*@' Config/Sentry.local.xcconfig 2>/dev/null; then
  echo "error: Config/Sentry.local.xcconfig is missing or wrong, so the app would read an empty or cut-off DSN. See docs/SENTRY.md."
  exit 1
fi
