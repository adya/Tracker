import CoreLocation

enum LocationTrackerStatus {
    case Unavailable
    case Disabled
    case Authorized
    case Denied
}


class LocationTracker : NSObject, CLLocationManagerDelegate {
    
    static let sharedTracker = LocationTracker()
    
    let locationManager : CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = 5
       // locationManager.activityType = .Fitness
    }
    
    var delegate : CLLocationManagerDelegate?
    
    func start() {
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 5
    }
    
    func stop() {
        //locationManager.stopUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 1000
    }
    
    func checkLocationAvailability() -> LocationTrackerStatus {
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location services are disabled on the device.")
            return .Disabled
        }
        
        guard CLLocationManager.isMonitoringAvailableForClass(CLRegion.self) else {
            print("Region monitoring is not available on the device.")
            return .Unavailable
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            return .Authorized
        case .NotDetermined, .Denied, .Restricted:
            self.locationManager.requestWhenInUseAuthorization()
            if NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription") == nil {
                print("Info.plist does not contain NSLocationWhenInUseUsageDescription")
            }
            return .Denied
        }
    }
}

extension LocationTracker {
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("You are at (\(String(format: "%.6f", location.coordinate.latitude)), " +
                "\(String(format: "%.6f", location.coordinate.longitude)))")
            LocationSender.sharedSender.sendLocation(location.coordinate)
        }
        delegate?.locationManager?(manager, didUpdateLocations: locations)
    }
}