//
//  Comment.swift
//  buildthebay
//
//  Created by Matthew Gill on 4/10/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import Foundation

class Comment: NSObject {
    var commentID: String?
    var issueID: String?
    var creatorID: String?
    var commentCreationDate: Int = 0
    var commentDescription: String
    var commentImageURL: String?

    init(commentDescription: String) {
        self.commentDescription = commentDescription
    }

    static func parseComments(dict: [String: [String: Any]]) -> [Comment] {
        var newComments = [Comment]()
        for (id, comment) in dict {
            let newComment = Comment(commentDescription: "")
            newComment.commentID = id
            if let issueID = comment["issueID"] as? String {
                newComment.issueID = issueID
            }
            if let creatorID = comment["creatorID"] as? String {
                newComment.creatorID = creatorID
            }
            if let commentCreationDate = comment["commentCreationDate"] as? Int {
                newComment.commentCreationDate = commentCreationDate
            }
            if let commentDescription = comment["commentDescription"] as? String {
                newComment.commentDescription = commentDescription
            }
            if let commentImageURL = comment["commentImageURL"] as? String {
                newComment.commentImageURL = commentImageURL
            }
            newComments.append(newComment)
        }
        newComments = newComments.sorted {
            return $0.commentCreationDate < $1.commentCreationDate
        }
        return newComments
    }
}
