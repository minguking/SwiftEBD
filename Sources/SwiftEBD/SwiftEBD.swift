// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import ARKit

public enum EyeBlink {
    case left, right, both
}

public protocol EyeBlinkDetectorDelegate: AnyObject {
    func blinkDetected(side: EyeBlink)
}

public class EyeBlinkDetector: NSObject, ARSessionDelegate {
    
    /// Determines if the user's device supports the Face Tracking feature.
    public static var isSupported: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }
    
    /// Stores the last detected blink time to calculate the cooldown period.
    private var lastBlinkTime: Date?
    
    /// Once a blink is detected, it will not be detected again during this cooldown period. Default value is 1.0 second.
    public let blinkCoolDown: TimeInterval
    
    /**
     Sensitivity threshold for detecting a blink.
     
     - 0.5 ~ 0.6: Recommended range. Detects natural blinks while ignoring half-closed eyes.
     - 0.3 ~ 0.4: More sensitive. Detects even slight or partial blinks, but may increase false positives.
     - 0.7 or higher: Requires stronger eye closure. Users may feel their blinks are not being detected.
     */
    public let sensitivity: Float
    
    /// Whether blinks with both eyes closed should be detected.
    public let detectBothEyeClosed: Bool
    
    private let session = ARSession()
    
    public weak var delegate: EyeBlinkDetectorDelegate?
    
    public init(
        blinkCoolDown: TimeInterval = 1.0,
        sensitivity: Float = 0.6,
        detectBothEyeClosed: Bool
    ) {
        self.blinkCoolDown = blinkCoolDown
        self.sensitivity = sensitivity
        self.detectBothEyeClosed = detectBothEyeClosed
        super.init()
        session.delegate = self
    }
    
    public func start() {
        let configuration = ARFaceTrackingConfiguration()
        session.run(configuration, options: [])
    }
    
    public func stop() {
        session.pause()
    }
    
    func handleBlink(leftClosed: Bool, rightClosed: Bool) {
        let now = Date()
        
        /// Ignore detection during the cooldown period.
        if let lastTime = lastBlinkTime, now.timeIntervalSince(lastTime) < blinkCoolDown {
            return
        }
        
        /// Both eyes closed (blink).
        if leftClosed && rightClosed {
            if !detectBothEyeClosed {
                return
            } else {
                delegate?.blinkDetected(side: .both)
                lastBlinkTime = now
                return
            }
        }
        
        /// Left eye closed (blink).
        if leftClosed && !rightClosed {
            delegate?.blinkDetected(side: .left)
            lastBlinkTime = now
            return
        }
        
        /// Right eye closed (blink).
        if rightClosed && !leftClosed {
            delegate?.blinkDetected(side: .right)
            lastBlinkTime = now
            return
        }
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        
        /// Uses the front camera, so left and right are mirrored.
        let leftClosed = isEyeClosed(.eyeBlinkRight, from: faceAnchor)
        let rightClosed = isEyeClosed(.eyeBlinkLeft, from: faceAnchor)
        
        handleBlink(leftClosed: leftClosed, rightClosed: rightClosed)
    }
    
    private func isEyeClosed(_ eye: ARFaceAnchor.BlendShapeLocation, from anchor: ARFaceAnchor) -> Bool {
        let value = anchor.blendShapes[eye]?.floatValue ?? 0.0
        return value > sensitivity
    }
}

