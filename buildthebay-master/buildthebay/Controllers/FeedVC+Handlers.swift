//
//  FeedVC+Handlers.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/11/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import Firebase


extension FeedVC {
    @objc func createIssueButtonPressed() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                let issueFormVC = IssueFormVC()
                let issueFormNC = UINavigationController(rootViewController: issueFormVC)
                self.present(issueFormNC, animated: true, completion: nil)
            } else {
                self.alertUser()
            }
        }
    }

    @objc func filtersButtonPressed() {
        let filterVC = FilterVC()
        filterVC.delegate = self
        let filterNC = UINavigationController(rootViewController: filterVC)
        present(filterNC, animated: true, completion: nil)
    }

    @objc func profileImageButtontapped() {
        let profileVC = ProfileVC()
        profileVC.delegate = self
        profileVC.imageURL = self.imageURL
        let profileNC = UINavigationController(rootViewController: profileVC)
        present(profileNC, animated: true, completion: nil)
    }

    @objc func refreshControlTriggered() {
        IssueInteractor.shared.fetchIssues { (issues, error) in
            guard error == nil else { return }
            self.issues = issues
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }

    func alertUser() {
        let alert = UIAlertController(title: "Sign In", message: "Please log in to create an issue.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: { action in
            self.present(LoginRegisterVC(), animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}



extension FeedVC {
    @objc func showAllIssues() {
        filter = false
        Hacks.customViewDidLoad()
    }
}

extension FeedVC: FilterDelegate {
    func didPressSubmitButton(with formValues: [String : Any]) {
        filter = true
        self.filterValues = formValues
        tableView.setContentOffset(.zero, animated: true)
    }
}
