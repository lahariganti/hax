//
// FeedVC.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/4/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import SwiftyJSON

class FeedVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var imageURL: String = ""
    let refreshControl = UIRefreshControl()
    let profileImageButton = UIButton(type: .custom)
    let logoButton = UIButton(type: .custom)
    var createIssueButton = UIBarButtonItem()
    var filtersButton = UIBarButtonItem()

    var issues = [Issue]()
    var filter = false
    var filterValues: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .btbBlue

        if filter == false {
           fetchIssues()
        } else {
          fetchFilteredIssues()
        }

        createIssueButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createIssueButtonPressed))
        filtersButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filtersButtonPressed))

        setupNavBar()
        tableView.delegate = self
        tableView.dataSource = self
        setupTableView()
        fetchCurrentUserProfile()
        setupRefreshControl()

        let issueCell = UINib(nibName: "IssueCell", bundle: nil)
        tableView.register(issueCell, forCellReuseIdentifier: "IssueCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchCurrentUserProfile()
        if filter == false {
            fetchIssues()
        } else {
            fetchFilteredIssues()
        }


    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        SharedDatabase.issuesRef.removeAllObservers()
    }

    func setupNavBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .btbGreen

        profileImageButton.addTarget(self, action: #selector(profileImageButtontapped), for: .touchUpInside)
        logoButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        logoButton.translatesAutoresizingMaskIntoConstraints = false
        logoButton.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        logoButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true

        logoButton.setImage(UIImage(named: "btb"), for: .normal)

        profileImageButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.widthAnchor.constraint(equalToConstant: 34.0).isActive = true
        profileImageButton.heightAnchor.constraint(equalToConstant: 34.0).isActive = true
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.setBackgroundImage(UIImage(named: "space_invader"), for: .normal)
        profileImageButton.layer.cornerRadius = profileImageButton.frame.height / 2
        profileImageButton.clipsToBounds = true
        profileImageButton.layer.borderWidth = 2
        profileImageButton.layer.borderColor = UIColor.btbGreen.cgColor

        navigationItem.rightBarButtonItems = []
        navigationItem.leftBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(showAllIssues)), UIBarButtonItem(customView: logoButton)]

        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.fetchCurrentUserProfile()
                let profileImageBarButton = UIBarButtonItem(customView: self.profileImageButton)
                self.navigationItem.rightBarButtonItems = [profileImageBarButton, self.createIssueButton, self.filtersButton]
            } else {
                self.navigationItem.rightBarButtonItems = [self.filtersButton, self.createIssueButton]
            }
        }
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .btbBlue
        tableView.refreshControl = refreshControl
    }

    private func setupRefreshControl() {
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
    }

    private func fetchIssues() {
        IssueInteractor.shared.fetchIssues { (issues, error) in
            guard error == nil else { return }
            self.issues = issues
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func fetchCurrentUserProfile() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let uid = SharedDatabase.currentUser?.uid else { return }
            UserInteractor.shared.fetchUser(withId: uid) { (user, error) in
                guard error == nil else { return }
                DispatchQueue.main.async {
                    if let imageurl = user?.profileImageURL {
                        self.profileImageButton.sd_setBackgroundImage(with: URL(string: imageurl), for: .normal, completed: { (image, error, cache, url) in
                            self.profileImageButton.setImage(image, for: .normal)
                        })
                    }
                }
            }
        }
    }

    func fetchFilteredIssues() {
        if let zip = filterValues["zip"] as? String {
            IssueInteractor.shared.fetchFilteredIssues(zip, completionHandler: {(issues, error) in
                guard error == nil else { return }
                self.issues = issues
                self.tableView.reloadData()
            })
        }
    }
}


extension FeedVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.issues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let issue = self.issues[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "IssueCell", for: indexPath) as! IssueCell
        cell.delegate = self
        cell.selectionStyle = .none
        cell.configure(with: issue, titleLines: 2, descriptionLines: 3, zipIsHidden: true, typeIsHidden: true)
        return cell
    }
}

extension FeedVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailVC(issue: self.issues[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeedVC: IssueCellDelegate {
    func didPressLikeButton() {
        alertUser()
    }
    
//     MAJOR REFACTOR REQUIRED
    func didTapStatusLabel(of issue: Issue) {
        guard let uid = SharedDatabase.currentUser?.uid else { return }
        SharedDatabase.DB_REF.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let usersDict = snapshot.value as? [String: Any] {
                let issuesJSON = JSON(usersDict)
                if issuesJSON["isAdmin"] == true {
                    let alert = UIAlertController(title: "Update status", message: "", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Open", style: UIAlertAction.Style.default, handler: { action in
                        let updateIssueStatusDict = ["status": "Open"]
                        if let issueID = issue.issueID {
                            SharedDatabase.issuesRef.child(issueID).updateChildValues(updateIssueStatusDict)
                            Hacks.customViewDidLoad()
                        }
                    }))

                    alert.addAction(UIAlertAction(title: "Started", style: UIAlertAction.Style.default, handler: { action in
                        let updateIssueStatusDict = ["status": "Started"]

                        if let issueID = issue.issueID {
                            SharedDatabase.issuesRef.child(issueID).updateChildValues(updateIssueStatusDict)
                            Hacks.customViewDidLoad()
                        }
                    }))

                    alert.addAction(UIAlertAction(title: "In Progress", style: UIAlertAction.Style.default, handler: { action in
                        let updateIssueStatusDict = ["status": "In Progress"]

                        if let issueID = issue.issueID {
                            SharedDatabase.issuesRef.child(issueID).updateChildValues(updateIssueStatusDict)
                            Hacks.customViewDidLoad()
                        }
                    }))

                    alert.addAction(UIAlertAction(title: "Closed", style: UIAlertAction.Style.default, handler: { action in
                        let updateIssueStatusDict = ["status": "Closed"]

                        if let issueID = issue.issueID {
                            SharedDatabase.issuesRef.child(issueID).updateChildValues(updateIssueStatusDict)
                            Hacks.customViewDidLoad()
                        }
                    }))

                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: nil))

                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Access Denied", message: "You need to be an admin to change an issue's status", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension FeedVC: ProfileVCDelegate {
    func saveChangesButtonTapped() {
//       fetchCurrentUserProfile()
    }
}


extension FeedVC: IssueFormDelegate {
    func issueDidAdd() {
//        fetchIssues()
    }
}
