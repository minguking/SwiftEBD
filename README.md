# SwiftEBD: Eye Blink Detector

A lightweight Swift library for detecting **eye blinks** using ARKit’s face tracking.  
It lets you detect left, right, or both eye blinks with customizable sensitivity and cooldown.

> ⚠️ Works only on devices that support **ARKit Face Tracking**(TrueDepth camera, e.g. iPhone X or later / iPad 2018 or later)

---

## Requirements
- iOS 13.0+
- **Camera permission**  
  Add the following key to your `Info.plist`:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>This app uses the front camera for eye blink detection.</string>
  ```
---

## Features

- Detects **left eye**, **right eye**, or **both eyes** blinks
- Adjustable **sensitivity threshold**
- Configurable **cooldown period** to avoid duplicate detections
- Option to **ignore both-eye blinks**
- Simple delegate-based API

---

## Installation

### Swift Package Manager (SPM)

Add `SwiftEBD` as a dependency in your project:

1. In Xcode, go to  
   **File → Add Packages…**  
2. Enter the repository URL:
   ```shell
   https://github.com/minguking/SwiftEBD
   ```

3. Choose **Add Package**.

Or, in your `Package.swift`:

```swift
dependencies: [
 .package(url: "https://github.com/minguking/SwiftEBD", from: "1.0.0")
]
```

---

## Usage

### Import the Library
```swift
import SwiftEBD
```

### Implement the delegate
```swift
import UIKit
import SwiftEBD

class ViewController: UIViewController, EyeBlinkDetectorDelegate {

    var detector: EyeBlinkDetector?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check device support
        guard EyeBlinkDetector.isSupported else {
            print("Face tracking not supported on this device")
            return
        }

        // Initialize detector
        detector = EyeBlinkDetector(
            blinkCoolDown: 1.0,
            sensitivity: 0.6,
            ignoreWhenBothEyeClosed: false
        )
        detector?.delegate = self
        detector?.start()
    }

    func blinkDetected(side: EyeBlink) {
        switch side {
        case .left:
            print("Left eye blink detected")
        case .right:
            print("Right eye blink detected")
        case .both:
            print("Both eyes blink detected")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detector?.stop()
    }
}
```
