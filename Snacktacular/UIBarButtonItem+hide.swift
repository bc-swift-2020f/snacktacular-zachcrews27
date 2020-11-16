//
//  UIBarButtonItem+hide.swift
//  Snacktacular
//
//  Created by Zach Crews on 11/15/20.
//  Copyright © 2020 Zachary Crews. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
