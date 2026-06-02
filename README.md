# RunAna

RunAna is a standalone SwiftUI iPhone app prototype for analyzing running app screenshots with OpenAI Vision.

## Features

- Upload one running screenshot from Photos
- Analyze pace, elevation, runner level, and next goal
- Short bilingual Chinese + English output
- Blue, green, and yellow themes
- Local free limit of 2 analyses per day
- Demo Pro paywall placeholder
- Light blue app icon with a white runner silhouette

## OpenAI key

For local testing, add the key inside the app settings screen. Do not hard-code OpenAI API keys into the iOS client. A production app should call your own backend, and the backend should store the OpenAI key in an environment variable.

The key previously pasted into chat should be revoked and regenerated.

## Open

```sh
open RunAna.xcodeproj
```

The current machine may need full Xcode selected before `xcodebuild` can compile iOS apps.
