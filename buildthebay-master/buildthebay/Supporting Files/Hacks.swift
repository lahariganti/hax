//
//  Hacks.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/11/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit

class Hacks {
    static func customViewDidLoad() {
        let windows = UIApplication.shared.windows
        for window in windows {
            for view in window.subviews {
                view.removeFromSuperview()
                window.addSubview(view)
            }
        }
    }
}
