//
//  MainDataManager.swift
//  ServoControl
//
//  Created by Alex Vihlayew on 21/09/2017.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

import Foundation
import CoreBluetooth

class MainDataManager: NSObject {
    
    lazy var bluetoothManager: CBCentralManager = {
        let bluetoothManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .userInteractive))
        return bluetoothManager
    }()
    
    func start() {
        _ = bluetoothManager
    }
    
    func stop() {
        bluetoothManager.stopScan()
    }
    
}

extension MainDataManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
        case .resetting:
            print("Resetting..")
        case .unauthorized:
            print("Anauthorized")
        case .unknown:
            print("Unknown state")
        case .poweredOff:
            print("Powered off")
        case .unsupported:
            print("Unsupported")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered:", peripheral.name ?? "Noname", advertisementData, RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected:", peripheral.name ?? "Noname")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect:", peripheral.name ?? "Noname")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected:", peripheral.name ?? "Noname")
    }
    
}
