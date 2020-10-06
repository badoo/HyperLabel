#!/bin/bash

set -o pipefail

xcodebuild clean build test \
    -project HyperLabel.xcodeproj \
    -scheme HyperLabel \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 11' \
    -configuration Debug | xcpretty
