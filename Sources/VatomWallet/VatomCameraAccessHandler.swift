import AVFoundation
import Foundation

public class VatomCameraAccessHandler: NSObject {
    private var cameraAccessContinuation: CheckedContinuation<Bool, Never>?

    func requestCameraAccess() async -> Bool {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch authorizationStatus {
        case .notDetermined:
            // The user has not yet been asked for camera access
            return await withCheckedContinuation { continuation in
                self.cameraAccessContinuation = continuation
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
        case .restricted, .denied:
            // The user has previously denied access
            return false
        case .authorized:
            // The user has previously granted access
            return true
        @unknown default:
            fatalError("Unhandled authorization status")
        }
    }
}
