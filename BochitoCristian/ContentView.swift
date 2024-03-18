//
//  ContentView.swift
//  BochitoCristian
//
//  Created by Daniel Atondo on 18/03/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) {
                Text("Vochito")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                
                Text("iOS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
            }
            .padding(.bottom, 50)

            Button(action: {
                bluetoothManager.sendCommand("1")
            }) {
                Text("ON")
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15.0)
            }
            
             Button(action: {
                 bluetoothManager.sendCommand("0")
             }) {
                 Text("OFF")
                     .foregroundColor(.white)
                     .padding()
                     .frame(width: 200, height: 60)
                     .background(Color.red)
                     .cornerRadius(15.0)
             }
        }
        .padding()
        .alert(isPresented: $bluetoothManager.shouldShowConnectionAlert) {
            Alert(title: Text("Devices Detected"),
                  message: Text("Connect to \(bluetoothManager.detectedDeviceName ?? "unknown device")"),
                  primaryButton: .default(Text("Okay"), action: {
                      bluetoothManager.connectToDevice()
                  }),
                  secondaryButton: .cancel())
        }
    }
}
