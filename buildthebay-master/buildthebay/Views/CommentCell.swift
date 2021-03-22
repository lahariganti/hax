//
//  CommentCell.swift
//  buildthebay
//
//  Created by Matthew Gill on 4/11/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit

protocol CommentCellDelegate: class {
    func imageDidSet()
    func imageTapped(image: UIImage)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoWidthConstraint: NSLayoutConstraint!

    weak var delegate: CommentCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        userImage.contentMode = .scaleAspectFill
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.clipsToBounds = true
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = UIColor.btbGreen.cgColor

        photoImageView.layer.cornerRadius = 12
        photoImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        //                tap.delegate = self
        photoImageView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with comment: Comment) {
        if let creatorId = comment.creatorID {
            UserInteractor.shared.fetchUser(withId: creatorId) { (user, error) in
                guard error == nil, let user = user else { return }
                self.userImage.sd_setImage(with: URL(string: user.profileImageURL ?? ""), placeholderImage: #imageLiteral(resourceName: "home"), completed: nil)
                self.nameLabel.text = "\(user.name ?? "")"
            }
        }
        let date = Date(timeIntervalSince1970: TimeInterval(comment.commentCreationDate))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy  h:mm a"
        let dateString: String = dateFormatter.string(from: date as Date)
        dateLabel.text = dateString
        commentLabel.text = comment.commentDescription

        if comment.commentImageURL == nil {
            photoHeightConstraint.constant = 0
        } else {
            photoImageView.sd_setImage(with: URL(string: comment.commentImageURL ?? "")) { (image, error, cacheType, url) in
                guard error == nil, let image = image else { return }

                let ratio = image.size.width / image.size.height
                if image.size.width > image.size.height {
                    let newHeight = 160 / ratio
                    self.photoHeightConstraint.constant = newHeight
                    self.photoWidthConstraint.constant = 160
                } else {
                    let newWidth = 160 * ratio
                    self.photoHeightConstraint.constant = 160
                    self.photoWidthConstraint.constant = newWidth
                }
                self.delegate?.imageDidSet()

            }
        }
        layoutSubviews()
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let photo = photoImageView.image {
            delegate?.imageTapped(image: photo)
        }
    }
}
