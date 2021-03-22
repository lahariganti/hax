//
//  Issue.swift
//  buildthebay
//
//  Created by Frederico Murakawa on 4/5/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit

enum IssueCategory: String {
    case food = "Food"
    case water = "Water"
    case shelter = "Shelter"
    case education = "Education"
    case transportation = "Transportation"
    case ene = "Energy & Environment"
    case other = "Other"
}

class Issue: NSObject {
//    auto generated id = issueID
    var issueID: String?
    var title: String
    var issueDescription: String?
    var issueCreationDate: Int = 0
    var likes: Int = 0
    var creatorID: String?
    var alreadyLiked: Bool?
    var zip: String?
    var county: String?
    var status: String = "Open"
    var likers: Set<String> = []
    var type: IssueCategory?
    var comments: [Comment]?

    init(title: String) {
        self.title = title
    }

    static func parseIssues(dict: [String: [String: Any]]) -> [Issue] {
        var newIssues = [Issue]()
        for (id, issue) in dict {
            let newIssue = Issue(title: "")
            newIssue.issueID = id
            if let title = issue["title"] as? String {
                newIssue.title = title
            }
            if let descrip = issue["issueDescription"] as? String {
                newIssue.issueDescription = descrip
            }
            if let issueCreationDate = issue["issueCreationDate"] as? Int {
                newIssue.issueCreationDate = issueCreationDate
            }
            if let likes = issue["likes"] as? Int {
                newIssue.likes = likes
            }
            if let creatorID = issue["creatorID"] as? String {
                newIssue.creatorID = creatorID
            }
            if let zip = issue["zip"] as? String {
                newIssue.zip = zip
            }
            if let county = issue["county"] as? String {
                newIssue.county = county
            }
            if let likers = issue["likers"] as? [String] {
                newIssue.likers = Set(likers)
            }
            if let type = issue["type"] as? String {
                newIssue.type = IssueCategory(rawValue: "\(type.capitalized)")
            }
            if let status = issue["status"] as? String {
                newIssue.status = status
            }
            newIssues.append(newIssue)
        }
        newIssues = newIssues.sorted {
            return $0.issueCreationDate > $1.issueCreationDate
        }
        return newIssues
    }
}
