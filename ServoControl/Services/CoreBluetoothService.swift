//
//  CoreBluetoothService.swift
//  ServoControl
//
//  Created by Alex Vihlayew on 21/09/2017.
//  Copyright © 2017 Alex Vihlayew. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

enum CoreBluetoothServiceStatus: String {
    case Disconnected
    case Connected
}

protocol CoreBluetoothServiceDelegate: class {
    func statusDidChange(to: CoreBluetoothServiceStatus)
}

class CoreBluetoothService: NSObject {
    
    
    // MARK: - Singletone
    
    static let shared = CoreBluetoothService()
    private override init() { super.init() }
    
    
    // MARK: - Properties
    
    weak var delegate: CoreBluetoothServiceDelegate? {
        didSet {
            delegate?.statusDidChange(to: .Disconnected)
        }
    }
    var foundDevices = Set<CBPeripheral>()
    private var updateCallback: (()->())?
    
    var bluetoothManager = CBCentralManager()
    var connectedPeripheral: CBPeripheral? {
        didSet {
            if let connected = connectedPeripheral {
                savePeripheral()
                connected.delegate = self
                connected.discoverServices(nil)
            } else {
                connectedPeripheralCharacteristics = nil
            }
        }
    }
    var connectedPeripheralCharacteristics: CBCharacteristic? {
        didSet {
            if connectedPeripheralCharacteristics != nil {
                delegate?.statusDidChange(to: .Connected)
            } else {
                delegate?.statusDidChange(to: .Disconnected)
            }
        }
    }
    
    
    // MARK: - State control
    
    func start() {
        bluetoothManager.delegate = self
        _ = bluetoothManager
        bluetoothManager.scanForPeripherals(withServices: nil, options: nil)
    }
    func stop() {
        updateCallback = nil
        endScan()
        foundDevices = []
    }
    
    func startScan(withUpdateCallback callback: @escaping (()->())) {
        updateCallback = callback
        bluetoothManager.scanForPeripherals(withServices: nil, options: nil)
    }
    func endScan() {
        bluetoothManager.stopScan()
    }
    
    var waitingForConnection: CBPeripheral?
    func connect(toPeripheral peripheral: CBPeripheral) {
        if let connected = connectedPeripheral {
            waitingForConnection = peripheral
            disconnect(peripheral: connected)
        } else {
            bluetoothManager.connect(peripheral, options: nil)
        }
    }
    
    func disconnect(peripheral: CBPeripheral) {
        bluetoothManager.cancelPeripheralConnection(peripheral)
    }
    
    func resetFoundList() {
        endScan()
        foundDevices = []
    }
    
    func savePeripheral() {
        guard let UID = connectedPeripheral?.identifier.uuidString else {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.managedObjectContext
        let fetchRequest: NSFetchRequest<ConnectionData> = NSFetchRequest(entityName: "ConnectionData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteRequest)
        } catch {
            print(error.localizedDescription)
        }
        let entity = NSEntityDescription.entity(forEntityName: "ConnectionData", in: context)
        let connectionDefauts = ConnectionData(entity: entity!, insertInto: context)
        connectionDefauts.uuid = UID
        do {
            //context.insert(connectionDefauts)
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func restorePeripheral() {
        print("Trying to restore connection...")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.managedObjectContext
        let fetchRequest: NSFetchRequest<ConnectionData> = NSFetchRequest(entityName: "ConnectionData")
        do {
            let dataArr = try context.fetch(fetchRequest)
            if let data = dataArr.first {
                let UID = data.uuid
                if let neededPeripheral = foundDevices.filter({ (peripheral) -> Bool in
                    peripheral.identifier.uuidString == UID
                }).first {
                    bluetoothManager.connect(neededPeripheral, options: nil)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - Sending data
    
    func sendState(value1: Int, value2: Int, forSlider sliderNumber: Int) {
        if let connectedPeripheral = connectedPeripheral, let connectedPeripheralCharacteristics = connectedPeripheralCharacteristics {
            connectedPeripheral.writeValue("\(sliderNumber):\(value1):\(value2) ".data(using: .ascii)!, for: connectedPeripheralCharacteristics, type: .withoutResponse)
        }
    }
    
}

extension CoreBluetoothService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            start()
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
        foundDevices.insert(peripheral)
        if connectedPeripheral == nil {
            restorePeripheral()
        }
        print("Discovered:", peripheral.name ?? "Noname")
        updateCallback?()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        print("Connected:", peripheral.name ?? "Noname")
        waitingForConnection = nil
        updateCallback?()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect:", peripheral.name ?? "Noname")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        print("Disconnected:", peripheral.name ?? "Noname")
        if let device = waitingForConnection {
            bluetoothManager.connect(device, options: nil)
        }
        updateCallback?()
    }
    
}

extension CoreBluetoothService: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach({ (service) in
            connectedPeripheral?.discoverCharacteristics(nil, for: service)
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach({ (characteristics) in
            connectedPeripheralCharacteristics = characteristics
            print("Discovered characteristics:", characteristics)
        })
    }
    
}
