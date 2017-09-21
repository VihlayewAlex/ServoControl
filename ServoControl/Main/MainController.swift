//
//  MainController.swift
//  ServoControl
//
//  Created by Alex Vihlayew on 21/09/2017.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

import Foundation

class MainController {
    
    weak var userInterface: MainViewController?
    let dataManager = MainDataManager()
    
    init(withUI userInterface: MainViewController) {
        self.userInterface = userInterface
    }
    
    func sliderValueChangedForServo(withNumber servoNumber: Int, sliderNumber: Int) {
        print("Servo:", servoNumber, "Slider:", sliderNumber)
    }
    
    func servoButtonTapped(withNumber servoNumber: Int) {
        
    }
    
    func connectButtonTapped() {
        dataManager.start()
    }
    
}
