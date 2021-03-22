//
//  IssuesInteractor.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/10/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import Firebase

class IssueInteractor: NSObject {
    static let shared = IssueInteractor()

    func fetchIssues(completionHandler: @escaping (([Issue], Error?) -> Void)) {
        SharedDatabase.issuesRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: [String: Any]] else { return completionHandler([], nil)
            }
            completionHandler(Issue.parseIssues(dict: dict), nil)
        }
    }


//    NEED TO ADD MULTI QUERY SUPPORT

    func fetchFilteredIssues(_ zip: String, completionHandler: @escaping (([Issue], Error?) -> Void)) {
        SharedDatabase.issuesRef.queryOrdered(byChild: "zip").queryEqual(toValue: zip).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: [String: Any]] else { return completionHandler([], nil)
            }
            completionHandler(Issue.parseIssues(dict: dict), nil)
        }
    }

    func updateNumberOfLikes(of issue: Issue, completionHandler: @escaping ((Bool?, Error?) -> Void)) {
        guard let issueID = issue.issueID, let currentUser = Auth.auth().currentUser else { return }
        var liked = false
        SharedDatabase.DB_REF.child("issues/\(issueID)").runTransactionBlock({ (snapshot) -> TransactionResult in
            if var dict = snapshot.value as? [String: Any] {
                if let likers = dict["likers"] as? [String] {
                    issue.likers = Set(likers)
                    if issue.likers.contains(currentUser.uid) {
                        issue.likers.remove(currentUser.uid)
                        liked = false
                    } else {
                        issue.likers.insert(currentUser.uid)
                        liked = true
                    }
                    dict["likers"] = Array(issue.likers)
                } else {
                    dict["likers"] = [currentUser.uid]
                    issue.likers.insert(currentUser.uid)
                }
                issue.likes = issue.likers.count
                dict["likes"] = issue.likes
                snapshot.value = dict
            }
            return TransactionResult.success(withValue: snapshot)
        }, andCompletionBlock: { (error, success, snapshot) in
            guard error == nil, let snapshot = snapshot, success else { return completionHandler(success, error) }
            if var dict = snapshot.value as? [String: Any] {
                if let likers = dict["likers"] as? [String] {
                    issue.likers = Set(likers)
                }
                if let likes = dict["likes"] as? Int {
                    issue.likes = likes
                }
                completionHandler(liked, nil)
            }
        })
    }
}
