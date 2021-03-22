//
//  CustomTabBarController.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/7/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    let duration = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        tabBar.barTintColor = .white
        tabBar.tintColor = .btbGreen

        let feedNC = UINavigationController(rootViewController: FeedVC())
        feedNC.tabBarItem.image = UIImage(named: "home")
        let trendingNC = UINavigationController(rootViewController: TrendingVC())

        trendingNC.tabBarItem.image = UIImage(named: "fire")
        let libraryNC = UINavigationController(rootViewController: LibraryVC())
        libraryNC.tabBarItem.image = UIImage(named: "libraryUnfilled")

        viewControllers = [feedNC, trendingNC, libraryNC]
        if let VCs = viewControllers {
            for vc in VCs {
                vc.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            }
        }
    }
}
