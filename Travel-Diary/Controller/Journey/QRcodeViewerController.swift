//
//  QRcodeViewerController.swift
//  Travel-Diary
//
//  Created by 黃昱崴 on 2022/6/22.
//

import UIKit
import AVFoundation

class QRcodeViewerController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension QRcodeViewerController: AVCaptureMetadataOutputObjectsDelegate {
    
}
