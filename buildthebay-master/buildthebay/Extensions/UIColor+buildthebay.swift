//
//  UIColor+buildthebay.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/5/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit

extension UIColor {
    static var lightBackground: UIColor {
        return UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }

    static var darkBackground: UIColor {
        return UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    }

    static var accent: UIColor {
        return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    }

    static var btbGreen: UIColor {
        return UIColor(red: 77/265, green: 161/255, blue: 134/255, alpha: 1)
    }

    static var btbBlue: UIColor {
        return UIColor(red: 54/265, green: 152/255, blue: 206/255, alpha: 1)
    }
}


extension Dictionary {

    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }

    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}
