//
//  JSONViewController.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/16/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import UIKit

class JSONViewController: UIViewController{
    
    var JSON = ""
    @IBOutlet weak var JSONText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JSONText.text = JSON
    }
}
