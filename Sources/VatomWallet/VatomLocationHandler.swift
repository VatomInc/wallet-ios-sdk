import CoreLocation
import Foundation

public class VatomLocationHandler: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }

    func getCurrentPosition() async -> CLLocation? {
        guard CLLocationManager.locationServicesEnabled() else {
            // Location services are not enabled
            return nil
        }

        // Check the authorization status
        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            // Prior to iOS 14, use the class method
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        switch authorizationStatus {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            // Await the user's authorization response
            return await withCheckedContinuation { continuation in
                self.locationContinuation = continuation
            }
        case .restricted, .denied:
            // Location services are not allowed
            return nil
        case .authorizedWhenInUse, .authorizedAlways:
            // Check if there's an existing recent location
            if let location = locationManager.location,
               -location.timestamp.timeIntervalSinceNow <= 20 {
                // If the location is recent (within 20 seconds), return it
                return location
            } else {
                // Request a new location update
                locationManager.requestLocation()

                // Wait for the location update and return it
                return await withCheckedContinuation { continuation in
                    self.locationContinuation = continuation
                }
            }
        @unknown default:
            fatalError("Unhandled authorization status")
        }
    }

    // MARK: - CLLocationManagerDelegate

    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print("didUpdateLocations")
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
    }

    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationChange(manager.authorizationStatus)
    }

    // iOS 13 and below use this delegate method for changes in authorization
    public func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #available(iOS 14.0, *) {
            // If we're on iOS 14+, we should use locationManagerDidChangeAuthorization instead
            return
        }
        handleAuthorizationChange(status)
    }

    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // The user has not yet made a choice regarding whether the app can use location services.
            break
        case .restricted, .denied:
            // The user has denied the use of location services for the app or they are disabled globally in Settings.
            locationContinuation?.resume(returning: nil)
            locationContinuation = nil
        case .authorizedWhenInUse, .authorizedAlways:
            // The user has granted authorization, so let's get the location.
            locationManager.requestLocation()
        @unknown default:
            fatalError("Unhandled authorization status")
        }
    }
}
