//
//  LibraryVC.swift
//  buildthebay
//
//  Created by Lahari Ganti on 4/7/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit

class LibraryVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

    @IBOutlet weak var collectionView: UICollectionView!

    let myLibrary = ["myIssues", "myCity", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        each user's issues and issues he/she commented on
    }
}
