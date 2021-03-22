//
//  FullScreenImageVC.swift
//  buildthebay
//
//  Created by Matthew Gill on 4/12/19.
//  Copyright © 2019 Lahari Ganti. All rights reserved.
//

import UIKit

class FullScreenImageVC: UIViewController {
    let imageView = UIImageView()

    init(image: UIImage) {
        imageView.image = image
        super.init(nibName: nil, bundle: nil)
        view.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        modalTransitionStyle = .crossDissolve
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        view.addGestureRecognizer(tap)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
