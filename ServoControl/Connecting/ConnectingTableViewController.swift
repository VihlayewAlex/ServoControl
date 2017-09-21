//
//  ConnectingViewController.swift
//  ServoControl
//
//  Created by Alex Vihlayew on 21/09/2017.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

import UIKit

class ConnectingViewController: UIViewController {

    lazy var darkenView: UIView = {
        let darkenView = UIView()
        darkenView.backgroundColor = UIColor.black
        darkenView.frame = self.view.frame
        darkenView.layer.opacity = 0.0
        darkenView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return darkenView
    }()
    
    func darken() {
        let animation = CABasicAnimation()
        animation.fromValue = 0.0
        animation.toValue = 0.4
        animation.keyPath = "opacity"
        animation.duration = 0.3
        animation.isRemovedOnCompletion = true
        
        self.presentingViewController?.view.addSubview(darkenView)
        
        darkenView.layer.add(animation, forKey: "darkenAnimation")
        darkenView.layer.opacity = 0.4
    }
    
    func lighten() {
        let animation = CABasicAnimation()
        animation.fromValue = 0.4
        animation.toValue = 0.0
        animation.keyPath = "opacity"
        animation.duration = 0.3
        animation.isRemovedOnCompletion = true
        
        darkenView.layer.add(animation, forKey: "lightenAnimation")
        darkenView.layer.opacity = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        darken()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        lighten()
    }
    
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
