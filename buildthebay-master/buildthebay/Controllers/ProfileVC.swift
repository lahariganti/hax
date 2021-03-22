//
//  ProfileVC.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/8/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import SwiftyJSON
import Eureka


protocol ProfileVCDelegate: class {
    func saveChangesButtonTapped()
}

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: ProfileVCDelegate?

    let myLibrary: [String] = ["My County", "My Issues"]
    var selectedImageFromPicker: UIImage?

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var libraryTableView: UITableView!

    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }()

    var imageURL: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        libraryTableView.delegate = self
        libraryTableView.dataSource = self

        navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(closeButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(signOutButtonPressed))
        navigationController?.navigationBar.tintColor = .btbGreen

        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped)))
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.btbGreen.cgColor

        profileNameLabel.isUserInteractionEnabled = true
        profileNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileNameLabelTapped)))

        configureUser()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        configureUser()
    }

    func setupViews() {
        headerImageView.backgroundColor = .darkBackground
        profileImageView.backgroundColor = .white
        profileImageView.image = UIImage(named: "space_invader")
        profileImageView.layer.cornerRadius = 40
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true
        profileImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "space_invader"))

        saveChangesButton.layer.cornerRadius = 8
        saveChangesButton.addTarget(self, action: #selector(saveChangesButtonPressed), for: .touchUpInside)
        saveChangesButton.clipsToBounds = true
    }

    @objc func profileNameLabelTapped() {
        let editProfileVC = EditProfileVC()
        let editProfileNC = UINavigationController(rootViewController: editProfileVC)
        present(editProfileNC, animated: true, completion: nil)
    }

    @objc func profileImageViewTapped() {
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originmalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originmalImage
        }

        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }

        dismiss(animated: true, completion: nil)
    }

    func writeImageToDatabaseAndUpdateUI() {
        guard let uid = SharedDatabase.currentUser?.uid else {
            return
        }

        let storageRef = Storage.storage().reference().child("testImageNew.png")
        if let uploadData = self.profileImageView.image?.pngData() {
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
                        let usersRef = SharedDatabase.DB_REF.child("users")
                        let thisUserRef = usersRef.child(uid)
                        let profileImageData = ["profileImageURL": downloadURL]
                        thisUserRef.updateChildValues(profileImageData)
                    }
                })
            })
        }
    }

    private func configureUser() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let uid = SharedDatabase.currentUser?.uid else { return }
            UserInteractor.shared.fetchUser(withId: uid) { (user, error) in
                guard error == nil else { return }
                DispatchQueue.main.async {
                    if let name = user?.name {
                        self.profileNameLabel.text = name + "▼"
                        if let imageurl = user?.profileImageURL {
                            self.profileImageView.sd_setImage(with: URL(string: imageurl), completed: { (image, error, cache, url) in
                                self.profileImageView.image = image
                            })
                        }
                    }
                }
            }
        }
    }

    @objc func signOutButtonPressed() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch {
            print(error)
        }
    }

    @objc func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    @objc func saveChangesButtonPressed() {
        writeImageToDatabaseAndUpdateUI()
        delegate?.saveChangesButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myLibrary.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let libItem = self.myLibrary[indexPath.row]
        let cell = UITableViewCell()
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        cell.textLabel?.text = libItem
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}


extension ProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}
