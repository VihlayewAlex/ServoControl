//
//  MainController.swift
//  ServoControl
//
//  Created by Alex Vihlayew on 21/09/2017.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

import UIKit
import CoreData

class MainController {
    
    weak var userInterface: MainViewController?
    
    init(withUI userInterface: MainViewController) {
        self.userInterface = userInterface
        print("Will set delegate")
        CoreBluetoothService.shared.delegate = self
    }
    
    var sliderValues: [Float] = Array(repeating: 50, count: 8) {
        didSet {
            print("Sliders value changed to:", sliderValues)
        }
    }
    
    func sliderValueChangedForServo(withNumber servoNumber: Int, sliderNumber: Int, toValue value: Float) {
        sliderValues[((servoNumber - 1) * 2) + sliderNumber - 1] = value
        print("Servo:", servoNumber, "Slider:", sliderNumber)
        saveSlidersData()
    }
    
    func servoButtonTapped(withNumber servoNumber: Int) {
        let value1 = sliderValues[((servoNumber - 1) * 2)]
        let value2 = sliderValues[((servoNumber - 1) * 2) + 1]
        CoreBluetoothService.shared.sendState(value1: Int(value1), value2: Int(value2), forSlider: servoNumber)
    }
    
    func disableControls() {
        userInterface?.contentStackView.layer.opacity = 0.5
        userInterface?.contentStackView.tintColor = .darkGray
        userInterface?.contentStackView.isUserInteractionEnabled = false
    }
    
    func enableControls() {
        userInterface?.contentStackView.layer.opacity = 1.0
        userInterface?.contentStackView.tintColor = .blue
        userInterface?.contentStackView.isUserInteractionEnabled = true
    }
    
    func saveSlidersData() {
        print("Saving sliders data...")
        if let slider1value = userInterface?.slider1.value,
            let slider2value = userInterface?.slider2.value,
            let slider3value = userInterface?.slider3.value,
            let slider4value = userInterface?.slider4.value,
            let slider5value = userInterface?.slider5.value,
            let slider6value = userInterface?.slider6.value,
            let slider7value = userInterface?.slider7.value,
            let slider8value = userInterface?.slider8.value {
        
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.managedObjectContext
            let fetchRequest: NSFetchRequest<SlidersData> = NSFetchRequest(entityName: "SlidersData")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            do {
                try context.execute(deleteRequest)
            } catch {
                print(error.localizedDescription)
            }
            let entity = NSEntityDescription.entity(forEntityName: "SlidersData", in: context)
            let connectionDefauts = SlidersData(entity: entity!, insertInto: context)
            connectionDefauts.slider1 = slider1value
            connectionDefauts.slider2 = slider2value
            connectionDefauts.slider3 = slider3value
            connectionDefauts.slider4 = slider4value
            connectionDefauts.slider5 = slider5value
            connectionDefauts.slider6 = slider6value
            connectionDefauts.slider7 = slider7value
            connectionDefauts.slider8 = slider8value
            print(connectionDefauts)
            do {
                //context.insert(connectionDefauts)
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func restoreSlidersData() {
        print("Trying to restore sliders data...")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.managedObjectContext
        let fetchRequest: NSFetchRequest<SlidersData> = NSFetchRequest(entityName: "SlidersData")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let dataArr = try context.fetch(fetchRequest)
            print("Fetched data:", dataArr)
            if let data = dataArr.first {
                print("Setting values...", data)
                userInterface?.slider1.setValue(Float(data.slider1), animated: true)
                userInterface?.slider2.setValue(Float(data.slider2), animated: true)
                userInterface?.slider3.setValue(Float(data.slider3), animated: true)
                userInterface?.slider4.setValue(Float(data.slider4), animated: true)
                userInterface?.slider5.setValue(Float(data.slider5), animated: true)
                userInterface?.slider6.setValue(Float(data.slider6), animated: true)
                userInterface?.slider7.setValue(Float(data.slider7), animated: true)
                userInterface?.slider8.setValue(Float(data.slider8), animated: true)
                sliderValues = [data.slider1, data.slider2, data.slider3, data.slider4, data.slider5, data.slider6, data.slider7, data.slider8]
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

extension MainController: CoreBluetoothServiceDelegate {
    
    func statusDidChange(to: CoreBluetoothServiceStatus) {
        userInterface?.statusLabel.text = "Status: " + to.rawValue
        switch to {
        case .Connected:
            enableControls()
        case .Disconnected:
            disableControls()
        }
    }
    
}
