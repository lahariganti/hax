//
//  SharedDatabase.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/10/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import Foundation
import Firebase


class SharedDatabase {
    static let DB_REF = Database.database().reference(fromURL: "https://buildthebay.firebaseio.com/")
    static let currentUser = Auth.auth().currentUser

    static let usersRef = SharedDatabase.DB_REF.child("users")
    static let issuesRef = SharedDatabase.DB_REF.child("issues")
     static let commentsRef = SharedDatabase.DB_REF.child("comments")

    static let counties: [String] = ["San Francisco", "Solano Marin", "San Mateo", "Sonoma", "Alameda", "Napa", "Santa Clara", "Contra Costa", "Marin"]


    static let issueTypes = ["Food", "Water", "Shelter", "Education", "Transportation", "Energy & Environment", "Other"]
}
