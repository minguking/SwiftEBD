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
    
    /// determine if user's device supports Face Tracking feature
    public static var isSupported: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }
    
    /// stores last blink time to calculate cool down period
    private var lastBlinkTime: Date?
    
    /// Once detected, iit won't detect during this cool down period. Default is 1.0 second
    public let blinkCoolDown: TimeInterval
    
    /// If too sensitive, it might detect anomaly
    public let sensitivity: Float
    
    /// Whether to detect both eye close or not
    public let ignoreWhenBothEyeClosed: Bool
    
    private let session = ARSession()
    
    public weak var delegate: EyeBlinkDetectorDelegate?
    
    public init(
        blinkCoolDown: TimeInterval = 1.0,
        sensitivity: Float = 0.6,
        ignoreWhenBothEyeClosed: Bool
    ) {
        self.blinkCoolDown = blinkCoolDown
        self.sensitivity = sensitivity
        self.ignoreWhenBothEyeClosed = ignoreWhenBothEyeClosed
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
        
        /// ignore during cool time period
        if let lastTime = lastBlinkTime, now.timeIntervalSince(lastTime) < blinkCoolDown {
            return
        }
        
        /// Both eyes blink
        if leftClosed && rightClosed {
            if ignoreWhenBothEyeClosed {
                return
            } else {
                delegate?.blinkDetected(side: .both)
                lastBlinkTime = now
                return
            }
        }
        
        /// Left eye blink
        if leftClosed && !rightClosed {
            delegate?.blinkDetected(side: .left)
            lastBlinkTime = now
            return
        }
        
        /// Right eye blink
        if rightClosed && !leftClosed {
            delegate?.blinkDetected(side: .right)
            lastBlinkTime = now
            return
        }
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        
        /// it uses front camera, so left and right are reversed.
        let leftClosed = isEyeClosed(.eyeBlinkRight, from: faceAnchor)
        let rightClosed = isEyeClosed(.eyeBlinkLeft, from: faceAnchor)
        
        handleBlink(leftClosed: leftClosed, rightClosed: rightClosed)
    }
    
    private func isEyeClosed(_ eye: ARFaceAnchor.BlendShapeLocation, from anchor: ARFaceAnchor) -> Bool {
        let value = anchor.blendShapes[eye]?.floatValue ?? 0.0
        return value > sensitivity
    }
}

