import CoreLocation

protocol LocationSenderDelegate {
    func locationSender(sender : LocationSender, didSendLocation success : Bool)
}

class LocationSender {
    
    static let sharedSender = LocationSender()
    
    var delegate : LocationSenderDelegate?
    
    func sendLocation(location : CLLocationCoordinate2D, completion : ((success : Bool)->Void)? = nil) {
        let udid = "test01262017" //"7gry2g5f3r53f2"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let paramUrl = "http://52.20.198.95/ceiloc/api.php?API_ID=ndhebf63gfy3fgf&TYPE=SET_TRACKING&UDID=\(udid)&LAT=\(location.latitude)&LNG=\(location.longitude)"
            guard let url = NSURL(string: paramUrl) else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.locationSender(self, didSendLocation: false)
                    
                    completion?(success: false)
                }
                return
            }
            let request = NSURLRequest(URL: url)
            print("Sending '\(paramUrl)'")
            NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(request) { (data, _, error) in
                if let error = error {
                    print("\(error)")
                }
                guard error == nil,
                    let data = data where data.length > 0
                     else {
                        self.delegate?.locationSender(self, didSendLocation: false)
                        completion?(success: false)
                        return
                }
                if let string = String(data: data, encoding: NSUTF8StringEncoding) {
                    print("Received: \(string)")
                }
                self.delegate?.locationSender(self, didSendLocation: true)
                completion?(success: true)
            }.resume()
        }
    }
}