//
//  ViewController.swift
//  ServoControl
//
//  Created by Alex Vihlayew on 21/09/2017.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var servo1: UIButton!
    @IBOutlet weak var servo2: UIButton!
    @IBOutlet weak var servo3: UIButton!
    @IBOutlet weak var servo4: UIButton!
    
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!
    @IBOutlet weak var slider4: UISlider!
    @IBOutlet weak var slider5: UISlider!
    @IBOutlet weak var slider6: UISlider!
    @IBOutlet weak var slider7: UISlider!
    @IBOutlet weak var slider8: UISlider!
    
    //    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    lazy var eventHandler = MainController(withUI: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = eventHandler
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        eventHandler.restoreSlidersData()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let servoNum: Int = {
            switch sender.tag {
            case 1, 2:
                return 1
            case 3, 4:
                return 2
            case 5 ,6:
                return 3
            case 7, 8:
                return 4
            default:
                preconditionFailure("Unahndled slider tag")
            }
        }()
        let sliderNum: Int = {
            return ((sender.tag % 2) == 0) ? 2 : 1
        }()
        eventHandler.sliderValueChangedForServo(withNumber: servoNum, sliderNumber: sliderNum, toValue: sender.value)
    }
    
    @IBAction func servoButtonTapped(_ sender: UIButton) {
        //disableButtons()
        //Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(enableButtons), userInfo: nil, repeats: false)
        eventHandler.servoButtonTapped(withNumber: sender.tag)
    }
    
    @objc func enableButtons() {
        servo1.isEnabled = true
        servo2.isEnabled = true
        servo3.isEnabled = true
        servo4.isEnabled = true
        
        servo1.tintColor = .blue
        servo2.tintColor = .blue
        servo3.tintColor = .blue
        servo4.tintColor = .blue
    }
    
    func disableButtons() {
        servo1.isEnabled = false
        servo2.isEnabled = false
        servo3.isEnabled = false
        servo4.isEnabled = false
        
        servo1.tintColor = .darkGray
        servo2.tintColor = .darkGray
        servo3.tintColor = .darkGray
        servo4.tintColor = .darkGray
    }

}

