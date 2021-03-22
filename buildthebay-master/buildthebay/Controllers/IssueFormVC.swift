//
//  IssueFormVC.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/8/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import Firebase
import Eureka
import SwiftyJSON

protocol IssueFormDelegate: class {
    func issueDidAdd()
}

class IssueFormVC: FormViewController {
    weak var delegate: IssueFormDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateScroll = true
        rowKeyboardSpacing = 20
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))

            form +++ Section("")
                <<< TextRow(){ row in
                        row.tag = "issueTitle"
                        row.title = "Title"
                        row.placeholder = "Enter title here"
                        row.add(rule: RuleRequired(msg: "Required", id: "titleRule"))
                        row.validationOptions = .validatesOnChange
                        }.cellUpdate { cell, row in
                            if !row.isValid {
                                row.placeholder = ""
                                cell.titleLabel?.textColor = .red
                            }
                    }

                <<< TextAreaRow(){ row in
                        row.tag = "issueDescription"
                        row.title = "Description"
                        row.placeholder = "Enter description here"
                    }

                <<< TextRow(){ row in
                        row.tag = "issueZip"
                        row.title = "Zip Code"
                        row.placeholder = "Enter zip here"
                        row.add(rule: RuleMaxLength(maxLength: 5))
                        row.validationOptions = .validatesOnChange
                        }.cellUpdate { cell, row in
                            if !row.isValid {
                                row.placeholder = ""
                                cell.titleLabel?.textColor = .red
                            }
                    }

            form +++ Section("More Info")
                <<< PopoverSelectorRow<String>() { row in
                    row.tag = "issueType"
                    row.title = "Type"
                    row.options = SharedDatabase.issueTypes
                }

                <<< PopoverSelectorRow<String>() { row in
                    row.tag = "issueCounty"
                    row.title = "County"
                    row.options = SharedDatabase.counties
                }

                +++ Section("")
                    <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = "Submit"}.onCellSelection { [weak self] (cell, row) in
                        print("validating errors: \(String(describing: row.section?.form?.validate().count))")
                        if row.section?.form?.validate().count == 0 {
                            self?.createIssue(completionHandler: { (success, error) in
                                guard error == nil else { return }
                                 self?.delegate?.issueDidAdd()
                            })
                            self?.dismiss(animated: true, completion: nil)
                        }
                    }
    }

    @objc func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}

extension IssueFormVC {
    func createIssue(completionHandler: @escaping ((Bool, Error?) -> Void)) {
             guard let uid = Auth.auth().currentUser?.uid else { return }

            let issuesRef = SharedDatabase.DB_REF.child("issues")
            let issueCreatedRef = issuesRef.childByAutoId()

            let formValues = JSON(form.values())
            let issueTitle = formValues["issueTitle"].stringValue
            let issueType = formValues["issueType"].stringValue
            let issueDescription = formValues["issueDescription"].stringValue
            let issueZip = formValues["issueZip"].stringValue
            let issueCreationDate = round(NSDate().timeIntervalSince1970)
            let alreadyLiked = false
            let issueCounty = formValues["issueCounty"].stringValue
            let issueStatus = "Open"

            let data = ["title": issueTitle,
                        "status": issueStatus,
                        "issueDescription": issueDescription,
                        "creatorID": uid,
                        "issueCreationDate": issueCreationDate,
                        "likes": 0,
                        "type": issueType,
                        "zip": issueZip,
                        "county": issueCounty,
                        "alreadyLiked": alreadyLiked] as [String : Any]

            issueCreatedRef.setValue(data) {(error, _) in
                guard error == nil else { return completionHandler(false, error) }
            }
    }
}
