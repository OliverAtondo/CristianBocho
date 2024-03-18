//
//  BluetoothManager.swift
//  BochitoCristian
//
//  Created by Daniel Atondo on 18/03/24.
//

import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    private var centralManager: CBCentralManager!
    @Published private(set) var connectedPeripheral: CBPeripheral?
    @Published var shouldShowConnectionAlert = false
    @Published var detectedDeviceName: String?
    
    private var targetCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func connectToDevice() {
        guard let peripheral = connectedPeripheral else { return }
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name, name == "VochitoBluetooth" else { return }
        connectedPeripheral = peripheral
        detectedDeviceName = name
        shouldShowConnectionAlert = true
        centralManager.stopScan()
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "FDC7")])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        services
            .filter { $0.uuid == CBUUID(string: "FDC7") }
            .forEach { peripheral.discoverCharacteristics([CBUUID(string: "FD58")], for: $0) }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        targetCharacteristic = service.characteristics?.first { $0.uuid == CBUUID(string: "FD58") }
    }
    
    func sendCommand(_ command: String) {
        guard let data = command.data(using: .utf8),
              let characteristic = targetCharacteristic,
              let peripheral = connectedPeripheral else { return }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
}
