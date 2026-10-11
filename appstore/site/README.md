# Site captures

The hero loop and the tour screens on walkful.iamjarl.com (#200). The files the site
serves are in `website/assets/site/`. This folder holds how to make them again.

**Remake them whenever the Today, Insights or Coach screens change.** The site is public
imagery, and an old capture advertises old copy.

## Set up the simulator

An iPhone 17 Pro, so the captures are 1206 × 2622. Light appearance, and the status bar
Apple's marketing rules ask for: full signal, Wi-Fi and battery, at 9:41.

```bash
U=<iPhone 17 Pro UDID>
xcrun simctl spawn $U defaults write -g AppleLocale -string en_US    # da_DK for the Danish set
xcrun simctl spawn $U defaults write -g AppleLanguages -array en      # da for the Danish set
xcrun simctl shutdown $U; xcrun simctl boot $U
xcrun simctl ui $U appearance light
xcrun simctl status_bar $U override --time "9:41" --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --operatorName "" --batteryState discharging --batteryLevel 100
```

The locale has to be the simulator's own, not only a launch argument, or the status bar
writes the time in the wrong language.

## The app's site mode

A Debug build launched with `-screenshots -site`:

- the sample day sits under the 7,000 goal with no streak behind it, because the site shows
  no streaks;
- Today's ring starts empty and fills once over 2.4 s, then holds.

`-screen insights` and `-screen coach` open those screens instead.

## The loop

Record a cold launch, then find the cut on a contact sheet: about 0.6 s of empty ring before
the fill starts, then 6.6 s in all.

```bash
xcrun simctl io $U recordVideo --codec=h264 --force today-en-raw.mp4 &   # stop with Ctrl-C after ~12 s
xcrun simctl launch $U com.iamjarl.walkful -screenshots -site -AppleLanguages "(en)" -AppleLocale en_US
swift loopkit.swift sheet  today-en-raw.mp4 sheet.jpg 4 8 0.3 13
swift loopkit.swift encode today-en-raw.mp4 today-en.mp4 5.0 6.6 602 1308 1200000
swift loopkit.swift poster today-en.mp4 today-en-poster.jpg 6.4 602 1308 0.82
```

602 × 1308 is half the capture, sharp at the hero phone's 330 px. The loop comes out at about
270 KB. The poster is the held frame, so the page reads the same before the video plays,
without the script, and under reduce motion.

## The tour screens

```bash
xcrun simctl launch --terminate-running-process $U com.iamjarl.walkful -screenshots -site -screen insights \
  -AppleLanguages "(en)" -AppleLocale en_US
xcrun simctl io $U screenshot insights-en.png
sips -s format jpeg -s formatOptions 80 -z 1308 602 insights-en.png --out tour-insights-en.jpg
```

Today and Coach the same way.
