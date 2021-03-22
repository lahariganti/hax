//
//  CommentFormVC.swift
//  buildthebay
//
//  Created by Matthew Gill on 4/10/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import SwiftyJSON
import Firebase

protocol CommentFormDelegate: class {
    func commentDidAdd()
}

class CommentFormVC: FormViewController {
    let issue: Issue
    weak var delegate: CommentFormDelegate?

    init(issue: Issue) {
        self.issue = issue
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        animateScroll = true
        rowKeyboardSpacing = 20

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))
        
        form +++ Section("Compose")
            <<< TextAreaRow(){ row in
                row.tag = "commentDescription"
                row.title = "Description"
                row.placeholder = "Enter comment here"
                row.add(rule: RuleRequired(msg: "Required", id: "commentRule"))
                row.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        row.placeholder = ""
                        cell.textLabel?.textColor = .red
                    }
            }

            <<< ImageRow() {
                $0.tag = "commentImage"
                $0.title = "Attach an image"
                $0.sourceTypes = [.PhotoLibrary, .Camera]
                $0.clearAction = .yes(style: .default)
            }

            +++ Section("")
            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = "Submit"}.onCellSelection { [weak self] (cell, row) in
                print("validating errors: \(String(describing: row.section?.form?.validate().count))")
                if row.section?.form?.validate().count == 0 {
                    self?.createComment() { (success, error) in
                        guard error == nil else { return }
                        self?.delegate?.commentDidAdd()
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
        }
    }

    @objc func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}

extension CommentFormVC {
    func createComment(completionHandler: @escaping ((Bool, Error?) -> Void)) {
        let myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)

        let createdCommentRef = SharedDatabase.commentsRef.childByAutoId()
        guard let creatorID = SharedDatabase.currentUser?.uid else { return }

        var issueID: String = ""
        if let id = self.issue.issueID {
            issueID = id
        }
        var commentImage = UIImage()
        var commentDescription: String = ""

       let valuesDict = form.values()
        if let image = valuesDict["commentImage"] as? UIImage {
            commentImage = image
        }

        if let description = valuesDict["commentDescription"] as? String {
            commentDescription = description
        }

        createdCommentRef.setValue(["commentDescription": commentDescription, "issueID": issueID, "creatorID": creatorID, "commentCreationDate": round(Date().timeIntervalSince1970)]) { (error, _) in
            guard error == nil else {
                myActivityIndicator.stopAnimating()
                return completionHandler(false, error)
                
            }
        }

        let storageRef = Storage.storage().reference().child("commentImage.jpeg")
        if let uploadData = commentImage.jpegData(compressionQuality: 0.3) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }

                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!)
                        return
                    }

                    if let downloadURL = url?.absoluteString {
                        createdCommentRef.updateChildValues(["commentImageURL": downloadURL]) { (error, _) in
                            guard error == nil else { return completionHandler(false, error) }
                            myActivityIndicator.stopAnimating()
                            completionHandler(true, error)
                        }
                    }
                })
            })
        } else {
            myActivityIndicator.stopAnimating()
            completionHandler(true, nil)
        }
    }
}
