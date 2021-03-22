//
//  UsersInteractor.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/10/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import Firebase

class UserInteractor: NSObject {
    static let shared = UserInteractor()

    func fetchUser(withId id: String, completionHandler: @escaping ((User?, Error?) -> Void)) {
        SharedDatabase.usersRef.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else { return }
            completionHandler(User.parse(dict: dict),nil)
        }) { (error) in
            completionHandler(nil, error)
        }
    }
}
