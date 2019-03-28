//
//  ViewController.swift
//  Flashlight
//
//  Created by Jonathan Alland on 3/27/19.
//  Copyright © 2019 Jonathan Alland. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var Image: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (notification) in
            self.Image.alpha = 0
        }
    }
}
