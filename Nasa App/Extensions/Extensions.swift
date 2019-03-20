//
//  Extensions.swift
//  Nasa App
//
//  Created by Lucas Daniel on 28/02/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import UIKit
import SystemConfiguration
import CoreData

extension UIViewController {
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func showInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func dateToString(dateToConvert: String, actualFormat: String, newFormat: String) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = actualFormat
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = newFormat
        let date: Date? = dateFormatterGet.date(from: dateToConvert)
        let dateStr = dateFormatterPrint.string(from: date!)
        return dateStr
    }
    
    func stringToDate(dateToConvert: String, actualFormat: String, newFormat: String) -> Date? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = actualFormat
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = newFormat
        let date: Date? = dateFormatterGet.date(from: dateToConvert)
        let dateStr = dateFormatterPrint.string(from: date!)
        let dateFinal: Date? = dateFormatterPrint.date(from: dateStr)
        return dateFinal!
    }
}
    


