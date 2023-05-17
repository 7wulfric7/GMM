//
//  Extensions.swift
//  GMM
//
//  Created by Deniz Adil on 14.7.21.
//

import Foundation
import UIKit
import FirebaseStorageUI

//MARK: - Date Extension -

extension Date {
    public init?(with miliseconds: TimeInterval) {
        self = Date(timeIntervalSince1970: miliseconds / 1000.0)
    }
    
    func toMiliseconds() -> TimeInterval {
        return (self.timeIntervalSince1970 * 1000.0)
    }
    
    func timeAgoDisplay() -> String {
          let formatter = RelativeDateTimeFormatter()
          formatter.unitsStyle = .full
          formatter.dateTimeStyle = .numeric
          let dateString = formatter.localizedString(for: self, relativeTo: Date())
          if dateString.contains("second") {
              return "just now"
          }
          return dateString
      }
}

//MARK: - Error Alert Extension -

extension UIViewController {
    func showErrorWith(title: String?, msg: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Color (hex:) Extension -

extension UIColor {
    /**
        Creates an UIColor from HEX String in "#363636" format
        - parameter hexString: HEX String in "#363636" format
        - returns: UIColor from HexString
        */
       convenience init?(hex: String) {
           var hexFormatted: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
           if hexFormatted.hasPrefix("#") {
               hexFormatted = String(hexFormatted.dropFirst())
           }
           assert(hexFormatted.count == 6, "Invalid hex code used.")
           let scanner = Scanner(string: hexFormatted as String)
           var color: UInt64 = 0
           scanner.scanHexInt64(&color)
           let mask = 0x000000FF
           let r = Int(color >> 16) & mask
           let g = Int(color >> 8) & mask
           let b = Int(color) & mask
           let red   = CGFloat(r) / 255.0
           let green = CGFloat(g) / 255.0
           let blue  = CGFloat(b) / 255.0
           self.init(red: red, green: green, blue: blue, alpha: 1)
       }
       /**
        Creates an UIColor Object based on provided RGB value in integer
        - parameter red:   Red Value in integer (0-255)
        - parameter green: Green Value in integer (0-255)
        - parameter blue:  Blue Value in integer (0-255)
        - returns: UIColor with specified RGB values
        */
       convenience init(red: Int, green: Int, blue: Int) {
           assert(red >= 0 && red <= 255, "Invalid red component")
           assert(green >= 0 && green <= 255, "Invalid green component")
           assert(blue >= 0 && blue <= 255, "Invalid blue component")
           self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
       }
       var hexString: String {
           let colorRef = cgColor.components
           let r = colorRef?[0] ?? 0
           let g = colorRef?[1] ?? 0
           let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
           let a = cgColor.alpha
           var color = String(
               format: "#%02lX%02lX%02lX",
               lroundf(Float(r * 255)),
               lroundf(Float(g * 255)),
               lroundf(Float(b * 255))
           )
           if a < 1 {
               color += String(format: "%02lX", lroundf(Float(a)))
           }
           return color
       }
}

//MARK: - Email Validity Extension -

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

//MARK: - Loading Indicator Extension -

private var activityView: UIView?

extension UIViewController {
    
    func showLoadingSpinner() {
        activityView = UIView(frame: self.view.bounds)
        let activityIndicatior = UIActivityIndicatorView(style: .large)
        activityIndicatior.color = .lightGray
        guard let loadingView = activityView else {return}
        activityIndicatior.center = loadingView.center
        activityIndicatior.startAnimating()
        loadingView.addSubview(activityIndicatior)
        self.view.addSubview(loadingView)
    }
    
    func removeLoadingSpinner() {
        activityView?.removeFromSuperview()
        activityView = nil
    }
}

//MARK: - Load Images from Url Extension -

extension UIImageView {
    func setImageFrom(photoUrl : String?, photoReference : String?, placeholder: UIImage? = UIImage(named: "userPlaceholder")) {
        if let photoDownloadUrl = photoUrl ,  let url = URL(string: photoDownloadUrl){
            self.sd_setImage(with: url, placeholderImage: placeholder, options: [.refreshCached])
        }
        else if let photoReference = photoReference, !photoReference.isEmpty {
            let storageRef = Storage.storage().reference(forURL: photoReference)
            self.sd_setImage(with: storageRef, placeholderImage: placeholder)
        } else {
            self.image = placeholder
        }
    }
}

//MARK: - Blink Label When Button Pressed -

extension UILabel {
    func startBlink() {
        UIView.animate(withDuration: 0.2,
              delay:0.0,
              options:[.allowUserInteraction, .curveEaseInOut, .autoreverse],
              animations: { self.alpha = 0 }) { [weak self] success in
            if success {
                self?.stopBlink()
            }
        }
    }
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
