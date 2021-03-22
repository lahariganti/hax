//
//  FilterVC.swift
//  buildthebay
//
//  Created by Frederico Murakawa on 4/9/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import Eureka
import SwiftyJSON



protocol FilterDelegate: class {
    func didPressSubmitButton(with formValues: [String: Any])
}


class FilterVC: FormViewController {
    var formValues: [String: Any] = ["type": "", "county": "", "zip": ""]

    weak var delegate: FilterDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

         navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))
        
        animateScroll = true
        rowKeyboardSpacing = 20

        form +++ Section("Choose one or more")

            <<< MultipleSelectorRow<String>() { row in
                    row.tag = "type"
                    row.title = "Type"
                    row.options = SharedDatabase.issueTypes
                }.onPresent { from, to in
                        to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone))
                    }

            <<< MultipleSelectorRow<String>() { row in
                    row.tag = "county"
                    row.title = "County"
                    row.options = SharedDatabase.counties
                }.onPresent { from, to in
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(self.multipleSelectorDone))
                }

            <<< TextRow(){ row in
                row.tag = "zip"
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

            +++ Section("")
            <<< ButtonRow() {(row: ButtonRow) -> Void in row.title = "Search"}.onCellSelection { [weak self] (cell, row) in
                    self?.formValues["zip"] = self?.setZipToBeFiltered()
                    if let formValues = self?.formValues {
                        self?.delegate?.didPressSubmitButton(with: formValues)
                    }
                    self?.dismiss(animated: true, completion: nil)
                }
    }


    override func inputAccessoryView(for row: BaseRow) -> UIView? {
        return nil
    }

    func setZipToBeFiltered() -> String {
        let row: TextRow? = form.rowBy(tag: "zip")
        guard let value = row?.value else { return ""}
        return value
    }

    @objc func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    @objc func multipleSelectorDone() {
        self.formValues["type"] = form.values()["type"] as Any?
        self.formValues["county"] = form.values()["county"] as Any?
        navigationController?.popViewController(animated: true)
    }
}
