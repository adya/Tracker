import UIKit

let kResumedNotification = "AppResumed"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        if launchOptions?[UIApplicationLaunchOptionsLocationKey] != nil {
            print("We have: \(application.backgroundTimeRemaining)")
            LocationTracker.sharedTracker.start()
        }
            return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName(kResumedNotification, object: nil)
    }
}

