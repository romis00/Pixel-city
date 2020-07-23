//
//  3DPopVC.swift
//  Pixel-city
//
//  Created by Roman Tuzhilkin on 7/23/20.
//  Copyright © 2020 Roman Tuzhilkin. All rights reserved.
//

import UIKit

class _DPopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    
    var passedImage: UIImage!
    
    func initpassedImage(forImage image: UIImage) {
        self.passedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoubleTap()
        
        popImageView.image = passedImage
    }
    
    func addDoubleTap() {
        let doubletap = UITapGestureRecognizer(target: self, action: #selector(screenWasDpubleTapped))
        
        doubletap.numberOfTapsRequired = 2
        doubletap.delegate = self
        view.addGestureRecognizer(doubletap)
    }
    
    @objc func screenWasDpubleTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}
