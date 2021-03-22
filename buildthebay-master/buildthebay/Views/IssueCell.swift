//
//  IssueCell.swift
//  buildthebay
//
//  Created by Matthew Gill on 4/7/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import Firebase

protocol IssueCellDelegate: class {
    func didTapStatusLabel(of issue: Issue)
    func didPressLikeButton()
}

class IssueCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardShadowView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var backgroundInnerView: UIView!

    weak var delegate: IssueCellDelegate?
    var likeCount = 0
    var selectedIssue: Issue?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 10
        cardShadowView.layer.cornerRadius = 10
        likeButton.addTarget(self, action:#selector(likeButtonPressed), for: .touchUpInside)
        statusLabel.isUserInteractionEnabled = true
        statusLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(statusLabelTapped)))

        statusLabel.textColor = .btbGreen
        statusLabel.layer.shadowColor = UIColor.black.cgColor
        statusLabel.layer.shadowRadius = 1.0
        statusLabel.layer.shadowOpacity = 0.2
        statusLabel.layer.shadowOffset = CGSize(width: 1.4, height: 1.4)
        statusLabel.layer.masksToBounds = false
        typeLabel.textAlignment = .center

        background.layer.cornerRadius = 10
        backgroundInnerView.layer.cornerRadius = 10

        background.backgroundColor = .darkBackground
    }

    func configure(with issue: Issue, titleLines: Int = 0, descriptionLines: Int = 0, zipIsHidden: Bool = false, typeIsHidden: Bool = false) {
        self.selectedIssue = issue
        titleLabel.text = issue.title
        titleLabel.numberOfLines = titleLines
        statusLabel.text = issue.status
        descriptionLabel.text = issue.issueDescription
        descriptionLabel.numberOfLines = descriptionLines
        countyLabel.text = issue.county
        likeCountLabel.text = "\(issue.likes)"
        zipLabel.text = issue.zip
        zipLabel.isHidden = zipIsHidden
        typeLabel.textColor = .btbBlue
        if let type = issue.type {
            typeLabel.text = type.rawValue
        }
        typeLabel.isHidden = typeIsHidden
        if zipIsHidden, typeIsHidden {
            countyLabel.bottomAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 0).isActive = true
        }
        setImage()
    }

    private func setImage() {
        if let currentUser = Auth.auth().currentUser, let issue = selectedIssue {
            let image = issue.likers.contains(currentUser.uid) ? #imageLiteral(resourceName: "thumbs-up") : #imageLiteral(resourceName: "thumbs-up-empty")
            self.likeButton.setImage(image, for: .normal)
        }
    }

    @objc func likeButtonPressed(sender: UIButton) {
        if Auth.auth().currentUser != nil, let selectedIssue = self.selectedIssue {
            IssueInteractor.shared.updateNumberOfLikes(of: selectedIssue) { (liked, error) in
                guard error == nil, let _ = liked else { return }
                self.likeCountLabel.text = "\(selectedIssue.likes)"
                if let currentUser = Auth.auth().currentUser {
                    let image = selectedIssue.likers.contains(currentUser.uid) ? #imageLiteral(resourceName: "thumbs-up") : #imageLiteral(resourceName: "thumbs-up-empty")
                    UIView.transition(with: self.likeButton, duration: 0.3, options: .transitionFlipFromBottom, animations: {
                        self.likeButton.setImage(image, for: .normal)
                    }, completion: nil)
                }
            }
        } else {
            delegate?.didPressLikeButton()
        }
    }

    @objc func statusLabelTapped() {
        if let selectedIssue = self.selectedIssue {
            delegate?.didTapStatusLabel(of: selectedIssue)
        }
    }
}
