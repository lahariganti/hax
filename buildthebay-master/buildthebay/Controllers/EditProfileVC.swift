//
//  EditProfileVC.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/12/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import Foundation
import Eureka
import SwiftyJSON
import Firebase

class EditProfileVC: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))

        animateScroll = true
        rowKeyboardSpacing = 20

        form +++ Section("BASIC INFO")
            <<< TextRow(){ row in
                row.tag = "name"
                row.title = "Full Name"
                row.placeholder = "Enter name here"
                row.add(rule: RuleRequired(msg: "Required", id: "titleRule"))
                row.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        row.placeholder = ""
                        cell.titleLabel?.textColor = .red
                    }
            }

            +++ Section("MORE INFO")
                <<< ActionSheetRow<String>() {
                    $0.title = "Gender"
                    $0.selectorTitle = "Pick a number"
                    $0.options = ["Female", "Male", "Don't wish to identify"]
                    $0.value = "Female"
                }

                <<< TextRow(){ row in
                    row.tag = "county"
                    row.title = "County"
                    row.placeholder = "Alameda"
                }

            +++ SelectableSection<ListCheckRow<String>>("Where do you live", selectionType: .singleSelection(enableDeselection: true))

            let issues = SharedDatabase.counties
            for issue in issues {
                self.form.last! <<< ListCheckRow<String>(issue){ listRow in
                    listRow.title = issue
                    listRow.selectableValue = issue
                    listRow.value = nil
                }
            }

            form +++ Section("")
            <<< ButtonRow() { (row: ButtonRow) -> Void in row.title = "Submit"}.onCellSelection { [weak self] (cell, row) in
                print("validating errors: \(String(describing: row.section?.form?.validate().count))")
                if row.section?.form?.validate().count == 0 {
                    self?.updateUserDetails()
                    self?.dismiss(animated: true, completion: nil)
                }
        }

    }

    @objc func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}

extension EditProfileVC {
    func updateUserDetails() {
        guard let uid = SharedDatabase.currentUser?.uid else { return }
        let usersRef = SharedDatabase.usersRef
        let currentUserRef = usersRef.child(uid)
        let row: TextRow? = form.rowBy(tag: "name")
        let value = row?.value
        currentUserRef.updateChildValues(["name": value])
    }
}

