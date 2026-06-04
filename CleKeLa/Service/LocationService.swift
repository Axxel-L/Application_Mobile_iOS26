import CoreLocation

/// Appelle `onLocation` quand une position est trouvée.
/// Code fournie par l'API
class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var onLocation: ((CLLocation?) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        onLocation?(locations.first)
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        onLocation?(nil)
    }
}
