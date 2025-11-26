//
//  UIViewController+Background.swift
//  Project LOVE
//
//  Created by SDC-USER on 25/11/25.
//
import UIKit

extension UIViewController {

    static let swizzleViewDidLoad: Void = {
        let originalSelector = #selector(UIViewController.viewDidLoad)
        let swizzledSelector = #selector(UIViewController.swizzled_viewDidLoad)

        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_viewDidLoad() {
        self.swizzled_viewDidLoad()  // calls original viewDidLoad
        self.view.backgroundColor = UIColor(named: "AppBackground")
    }
}
