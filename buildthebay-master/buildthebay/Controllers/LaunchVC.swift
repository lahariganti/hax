//
//  LaunchVC.swift
//
//
//  Created by Lahari Ganti on 4/10/19.
//

import UIKit

class LaunchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .btbBlue
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.present(CustomTabBarController(), animated: true, completion: nil)
        }
    }
}
