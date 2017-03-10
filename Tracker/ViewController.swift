import UIKit
import Foundation
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak private var bTrigger: UIButton!
    @IBOutlet weak private var lStatus: UILabel!
    @IBOutlet weak private var lLocation: UILabel!
    @IBOutlet weak private var bLocationAccess: UIButton!
    
    private var tracking : Bool = false
    private let locationTracker = LocationTracker.sharedTracker
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(resumed), name: kResumedNotification, object: nil)
        locationTracker.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        bTrigger.enabled = checkLocationAvailability()
        LocationSender.sharedSender.delegate = self
    }
    
  
    private func checkLocationAvailability() -> Bool {
        let status = locationTracker.checkLocationAvailability()
        switch status {
        case .Denied:
            showMessage("You need to enable Location Services in your settings in order to use Location Tracker.")
            
            setLocationStatus("Enable Location Services")
        case .Unavailable:
            setLocationStatus("Location Services are unavailable on your device")
        case .Authorized:
            setLocationStatus()
        case .Disabled:
            setLocationStatus("Allow app to use Location Services")
        }
        return status == .Authorized
    }
    
    
    private func setLocationStatus(message : String? = nil) {
        self.bLocationAccess.setTitle(message, forState: .Normal)
        self.bLocationAccess.hidden = message == nil
    }
    
    private func showMessage(string : String) {
        let controller = UIAlertController(title: "Tracker", message: string, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Cancel",  style: .Cancel) { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        controller.addAction(UIAlertAction(title: "Open Settings", style: .Default) { _ in
                self.openSettings()
            self.dismissViewControllerAnimated(true, completion: nil)
            })
        presentViewController(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func triggerAction(sender: UIButton) {
        if tracking {
            locationTracker.stop()
        } else {
            locationTracker.start()
        }
        tracking = !tracking
        sender.setTitle(tracking ? "Stop Tracking" : "Start Tracking", forState: .Normal)
    }
    
    @IBAction func openSettings(sender: UIButton) {
        openSettings()
    }
    
    private func openSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string : UIApplicationOpenSettingsURLString)!)
    }
    
    @objc private func resumed(notification : NSNotification) {
        locationTracker.start()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension ViewController : CLLocationManagerDelegate, LocationSenderDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        if locations.count == 1 {
            bTrigger.enabled = checkLocationAvailability()
        }
        lStatus.text = "Updating..."
        lLocation.text = "You are at (\(String(format: "%.6f", location.coordinate.latitude)), " +
                   "\(String(format: "%.6f", location.coordinate.longitude)))"
    }
    
    func locationSender(sender : LocationSender, didSendLocation success : Bool) {
        lStatus.text = success ? "Updated" : "Failed"
    }
}

