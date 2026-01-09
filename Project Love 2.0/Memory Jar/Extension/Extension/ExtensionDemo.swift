//
//  ExtensionDemo.swift
//  Extension
//
//  Created by SDC-USER on 09/01/26.
//

import Foundation
import UIKit

extension UIColor {
    static var random: UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
         return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
