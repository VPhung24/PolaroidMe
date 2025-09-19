# PolaroidMe

A simple iOS demo app showing nano banana generation capabilities from an image

## Features

- Convert photos into classic Polaroid format with white borders and filter (yes, this could be done natively but this is fun nano banana app)
- Clean, native SwiftUI interface

## Requirements

- iOS 17.6+
- Xcode 15.0+
- Firebase project with `FirebaseAI` enabled 

## Technology Stack

- **SwiftUI** - Native iOS UI framework
- **`FirebaseAI` Swift SDK** - For secure Gemini AI integration

## Why `FirebaseAI` Swift SDK?

This app uses the Firebase AI Swift SDK instead of direct API calls because:

- Google Gemini doesn't offer a native Swift SDK
- Storing API keys in iOS clients is insecure
- Firebase provides App Check with Apple's DeviceCheck for enhanced security
- Protects against unauthorized API usage and abuse

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
