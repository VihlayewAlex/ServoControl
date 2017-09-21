//
//  ViewController.swift
//  ServoControl
//
//  Created by Alex Vihlayew on 21/09/2017.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    lazy var eventHandler = MainController(withUI: self)
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let servoNum: Int = {
            switch sender.tag {
            case 1, 2:
                return 1
            case 3, 4:
                return 2
            case 5 ,6:
                return 3
            default:
                preconditionFailure("Unahndled slider tag")
            }
        }()
        let sliderNum: Int = {
            return ((sender.tag % 2) == 0) ? 2 : 1
        }()
        eventHandler.sliderValueChangedForServo(withNumber: servoNum, sliderNumber: sliderNum)
    }
    
    @IBAction func servoButtonTapped(_ sender: UIButton) {
        eventHandler.servoButtonTapped(withNumber: sender.tag)
    }
    
    @IBAction func connectButtonTapped() {
        eventHandler.connectButtonTapped()
    }
    

}

