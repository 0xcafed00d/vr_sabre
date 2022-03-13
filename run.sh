#!/usr/bin/bash
adb push --sync . /sdcard/Android/data/org.lovr.app/files
adb shell am force-stop org.lovr.app
adb shell am start org.lovr.app/org.lovr.app.Activity