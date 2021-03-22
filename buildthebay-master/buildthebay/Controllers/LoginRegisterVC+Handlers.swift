//
//  LoginRegisterVC+Handlers.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/5/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit
import Firebase

extension LoginRegisterVC {
    @objc func handleLoginregister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
        getCurrentUserAndDismissLoginRegisterVC()
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Invalid Form")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { (User, error) in
            if error != nil {
                print(error as Any)
                return
            }
        }
    }

    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Invalid Form")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password, completion: { (User, error) in
            if error != nil {
                print(error!)
                return
            }

            guard let uid = User?.user.uid else {
                return
            }

            let userReference = SharedDatabase.DB_REF.child("users").child(uid)
            
            let values = ["name": name, "email": email, "isAdmin": false] as [String : Any]
            userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err as Any)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
        })
    }

    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any]) {
        let ref = Database.database().reference(fromURL: "https://buildthebay.firebaseio.com")
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err as Any)
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }


    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)

        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150

        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true

        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true

        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }

    func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }


    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: -90, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }

    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }

    fileprivate func getCurrentUserAndDismissLoginRegisterVC() {
        dismiss(animated: true, completion: nil)
    }
}
