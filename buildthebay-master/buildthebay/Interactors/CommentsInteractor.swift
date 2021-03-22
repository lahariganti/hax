//
//  CommentsInteractor.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/11/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import Foundation

class CommentsInteractor: NSObject {
    static let shared = CommentsInteractor()

    func fetchComments(of issue: Issue, completionHandler: @escaping (([Comment], Error?) -> Void)) {
        SharedDatabase.commentsRef.queryOrdered(byChild: "issueID").queryEqual(toValue: issue.issueID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: [String: Any]] else { return completionHandler([], nil)
            }
            completionHandler(Comment.parseComments(dict: dict), nil)
        }
    }
}
