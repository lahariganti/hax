//
//  User.swift
//  buildthebay
//
//  Created by Frederico Murakawa on 4/5/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit

//enum Permission {
//    case regular
//    case admin
//}

class User: NSObject {
    var name: String?
    var email: String?
    var profileImageURL: String?
    var isAdmin: Bool?
    var county: String?
    var state: State?
    var city: String?
    var zipcode: Int?

    static func parse(dict: [String: Any]) -> User {
        let newUser = User()
        if let name = dict["name"] as? String {
            newUser.name = name 
        }
        if let email = dict["email"] as? String {
            newUser.email = email
        }
        if let profileImageURL = dict["profileImageURL"] as? String {
            newUser.profileImageURL = profileImageURL
        }
        if let isAdmin = dict["isAdmin"] as? Bool {
            newUser.isAdmin = isAdmin
        }
        if let city = dict["city"] as? String {
            newUser.city = city
        }
        if let zipcode = dict["zipcode"] as? Int {
            newUser.zipcode = zipcode
        }

        return newUser
    }
}
