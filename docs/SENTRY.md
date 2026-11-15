# Sentry: anonymous crash reports and two counts

Walkful sends anonymous crash reports, diagnostics and two feature counts to Sentry (#222). It
follows the portfolio's anonymous recipe. Health data never leaves the device, and nothing read
from HealthKit, or derived from it, goes into anything Sentry receives.

The code is one file, [`Walkful/Core/Diagnostics/Telemetry.swift`](../Walkful/Core/Diagnostics/Telemetry.swift),
and its rules are tested in [`Tests/TelemetryTests.swift`](../Tests/TelemetryTests.swift).

## What leaves the phone

| Kind | What it is | Why |
|---|---|---|
| Crash reports | Crashes and hangs, with a stack trace, the app and iOS version, and the device model | To find and fix crashes |
| Sessions | One per app launch, so Sentry can show the share of crash-free sessions | To see whether a release made things worse |
| MetricKit diagnostics | Apple's own daily reports of hangs, disk writes and CPU use | Performance problems that don't crash |
| `screen.opened` | A count, with `screen` set to `today`, `insights`, `settings`, `coach` or `paywall` | Which parts of the app get used |
| `reminders.turned_on` | A count of 1 when move reminders are switched on. No hours, no other setting | Whether reminders are worth more work |

Nothing else. In particular:

- **No ID of any kind.** Every install reports as the same user, `anonymous`. No installation ID,
  no vendor-ID hash, no device ID. With `sendDefaultPii` off the SDK tells Sentry
  `infer_ip: never`, so no IP address is stored either.
- **Nothing from HealthKit or derived from it:** no steps, distance, goals, streaks, dates or
  records, in any event, breadcrumb, tag, attribute or count.
- **No screenshots, no view hierarchy, no session replay, no automatic breadcrumbs.** Today shows
  the day's steps, and an automatic breadcrumb can carry a control's on-screen text.
- **No performance traces** (`tracesSampleRate = 0`).

The App Store label for this is Diagnostics (Crash Data, Performance Data) and Usage Data
(Product Interaction), all "Data Not Linked to You" and not used for tracking. The same three
types are declared in [`Walkful/PrivacyInfo.xcprivacy`](../Walkful/PrivacyInfo.xcprivacy).

## The recipe

Out of the box, sentry-cocoa is not anonymous. It sends a random installation ID as the user, as
every session's `did` and on every metric, and a hash of the vendor ID on every event. Each line
below closes one of those.

| Sentry's default | What Walkful does |
|---|---|
| The user is a random installation ID | `SentrySDK.setUser(User(userId: "anonymous"))` right after start, and `beforeSend` sets it again on every event |
| Every session's `did` is the installation ID, read from the `INSTALLATION` file in the SDK's cache directory | Before `SentrySDK.start`, `pinInstallationID` writes `anonymous` into that file. Sessions can't be given a user any other way |
| `contexts.app.device_app_hash` and `contexts.device.id` on every event | `beforeSend` removes both |
| Metrics carry `user.id` and whatever else the SDK adds | `beforeSendMetric` keeps only an allowlist: the SDK's name and version, environment, release, OS, device brand, model and family, and `screen` |
| Binary paths name the install's container (`/private/var/containers/Bundle/Application/<UUID>/…`) | `beforeSend` cuts every image's `code_file` and every frame's `package` to the file name |
| `sendDefaultPii`, screenshots, view hierarchy, breadcrumbs, network capture | All off |

`environment` is `simulator`, `debug`, `testflight` (a sandbox receipt) or `production`, so test
runs aren't read as real crashes.

Sentry is never started under XCTest or in the screenshot mode (`-screenshots`).

## The DSN

The DSN never goes in git.

- **Locally:** copy `Config/Sentry.local.xcconfig.example` to `Config/Sentry.local.xcconfig`
  (git-ignored) and fill in the DSN from Sentry, under Settings, Projects, walkful, Client Keys.
  Without that file the DSN is empty and the app never starts Sentry, which is the normal state
  for a local build.
- **On Xcode Cloud:** add `SENTRY_DSN` as a secret environment variable on the workflow.
  `ci_scripts/ci_post_clone.sh` writes it into `Config/Sentry.local.xcconfig`.

`Config/Sentry.xcconfig` includes the local file, and `project.yml` passes `$(SENTRY_DSN)` into
Info.plist as `SentryDSN`, where `Telemetry` reads it.

**An xcconfig reads `//` as the start of a comment**, so a DSN written plainly is cut off after
`https:`. That is why the slashes are written `https:$(SLASH)$(SLASH)…`, with `SLASH = /` set in
`Config/Sentry.xcconfig`. `ci_post_clone.sh` does the replacement itself.

**An archive without a DSN stops.** `ci_scripts/ci_pre_xcodebuild.sh` fails the archive if
`SENTRY_DSN` is unset, isn't shaped like `https://<key>@<host>/<project>`, or didn't make it into
`Config/Sentry.local.xcconfig` with the `$(SLASH)` form. Otherwise a release would ship with crash
reports silently off. Builds and tests without an archive still run without it.

## Symbols

After an archive, `ci_scripts/ci_post_xcodebuild.sh` uploads the dSYMs with sentry-cli (pinned
version, checked against its SHA-256), so stack traces arrive readable. It needs
`SENTRY_AUTH_TOKEN` as a secret on the workflow. The token never goes in the repo. Without it the
release still builds, with a warning, and its crashes arrive unsymbolicated. `SENTRY_ORG` and
`SENTRY_PROJECT` default to `iamjarl` and `walkful`.

## The envelope check, after every SDK upgrade

The recipe leans on how sentry-cocoa behaves inside (the `INSTALLATION` file above all), so a new
SDK version can quietly undo it. After every upgrade, read what actually leaves the phone:

1. Run a small local stand-in for Sentry that saves every envelope it receives:

   ```python
   # fake_sentry.py: python3 fake_sentry.py <folder>
   import gzip, http.server, os, sys, time, zlib
   OUT = sys.argv[1]
   class H(http.server.BaseHTTPRequestHandler):
       def do_POST(self):
           body = self.rfile.read(int(self.headers.get("Content-Length", 0)))
           enc = (self.headers.get("Content-Encoding") or "").lower()
           if enc == "gzip": body = gzip.decompress(body)
           elif enc == "deflate": body = zlib.decompress(body)
           open(os.path.join(OUT, f"{time.time():.3f}.envelope"), "wb").write(body)
           self.send_response(200); self.end_headers(); self.wfile.write(b"{}")
       def log_message(self, *a): pass
   http.server.ThreadingHTTPServer(("127.0.0.1", 8971), H).serve_forever()
   ```

2. Build Debug for a simulator and install it. To prove the pin replaces an existing ID, write a
   recognisable fake one into the app's data container first, at `Library/Caches/INSTALLATION`
   (the default `options.cacheDirectoryPath`; check it hasn't moved in the new version). Get the
   container with `xcrun simctl get_app_container booted com.iamjarl.walkful data`, and check the
   path is inside the simulator's container before writing: if simctl fails, an empty result
   points at the Mac's own `/Library/Caches`.

3. Launch it pointed at the stand-in, with the DEBUG-only flag that sends one test event and both
   counts:

   ```bash
   SIMCTL_CHILD_SENTRY_DSN="http://0123456789abcdef0123456789abcdef@127.0.0.1:8971/1" xcrun simctl launch booted com.iamjarl.walkful -telemetryCheck
   ```

4. Read the envelopes. Pass means all of these hold:
   - the session's `did` is `anonymous`, and its attributes are only release and environment;
   - the event's user is `{"id":"anonymous"}`, with no `device_app_hash`, no `device.id`, no
     breadcrumbs, and empty tags and extra;
   - every `code_file` and frame `package` is a bare file name;
   - the SDK's settings say `"infer_ip":"never"`;
   - each `trace_metric` carries only allowlisted attributes, with no `user.*`;
   - neither the fake installation ID nor the container's UUID appears anywhere in any envelope.

`app_id` in the event is the binary's UUID (it matches `dwarfdump --uuid`), the same for everyone
on a build, so it isn't an install ID. The trace ID changes every launch.

**Last checked:** sentry-cocoa 9.34.0, 2026-11-15. Passed.

## Changing what is sent

Any change to telemetry goes through `Telemetry.swift` and this file. A new kind of data also
needs, in the same pull request:

- `Walkful/PrivacyInfo.xcprivacy`,
- the privacy policy (`website/privacy.html`),
- the in-app privacy caption in Settings,
- and the App Store privacy label, changed on the day the release goes out
  (`docs/app-store-release.md`).

A new count may only carry a fixed value from a list in the code, never a value from the user's
data.
