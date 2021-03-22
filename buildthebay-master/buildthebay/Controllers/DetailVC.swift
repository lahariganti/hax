//
//  DetailVC.swift
//  buildthebay
//
//  Created by Matthew Gill on 4/9/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import Firebase

class DetailVC: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private let issue: Issue
    private var comments = [Comment]()
    private let refreshControl = UIRefreshControl()

    init(issue: Issue) {
        self.issue = issue
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchComments()

        setupRefreshControl()
        tableView.refreshControl = refreshControl
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .btbBlue
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        let issueCell = UINib(nibName: "IssueCell", bundle: nil)
        tableView.register(issueCell, forCellReuseIdentifier: "IssueCell")
        let commentCell = UINib(nibName: "CommentCell", bundle: nil)
        tableView.register(commentCell, forCellReuseIdentifier: "CommentCell")
        setupNavBarItems()
    }

    private func setupRefreshControl() {
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
    }

    private func setupNavBarItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Comment", style: .plain, target: self, action: #selector(addCommentButtonPressed))
        navigationController?.navigationBar.tintColor = .btbGreen
    }

    private func fetchComments() {
        CommentsInteractor.shared.fetchComments(of: issue) { (comments, error) in
            guard error == nil else { return }
            self.comments = comments
            self.tableView.reloadData()
        }
    }

    @objc func addCommentButtonPressed() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                let commentFormVC = CommentFormVC(issue: self.issue)
                commentFormVC.delegate = self
                let commentFormNC = UINavigationController(rootViewController: commentFormVC)
                self.present(commentFormNC, animated: true, completion: nil)
            } else {
                self.alertUser()
            }
        }
    }

    func alertUser() {
        let alert = UIAlertController(title: "Sign In", message: "Please log in to add a comment.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler: { action in
            self.present(LoginRegisterVC(), animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }

    @objc func refreshControlTriggered() {
        CommentsInteractor.shared.fetchComments(of: issue) { (comments, error) in
            guard error == nil else { return }
            self.comments = comments
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
}

extension DetailVC: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IssueCell", for: indexPath) as! IssueCell
            cell.delegate = self
            cell.selectionStyle = .none
            cell.configure(with: issue)
            cell.cardShadowView.isHidden = true
            cell.backgroundColor = .white
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            cell.delegate = self
            cell.selectionStyle = .none
            cell.configure(with: comments[indexPath.row])
            return cell
        }
    }
}

extension DetailVC: IssueCellDelegate {
    func didPressLikeButton() {

    }

    func didTapStatusLabel(of issue: Issue) {

    }
}

extension DetailVC: CommentFormDelegate {
    func commentDidAdd() {
        fetchComments()
    }
}

extension DetailVC: CommentCellDelegate {
    func imageTapped(image: UIImage) {
        present(FullScreenImageVC(image: image), animated: true, completion: nil)
    }

    func imageDidSet() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
