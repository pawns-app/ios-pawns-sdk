import UIKit
import Foundation
import Combine

internal class Device: NSObject {
    
    internal var battery: Battery = .init()
    internal var isRunning: Bool = false
    
    override init() { 
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    internal func start() async -> AsyncStream<Battery> {
        
        NotificationCenter.default.removeObserver(self)
        
        self.observeBatteryState()
        self.observeBatteryLevel()
        
        return AsyncStream { continuation in
            
            continuation.yield(self.battery)
            
            let cancellable = Device.batterySubject.sink {
                continuation.yield($0)
            }
            
            continuation.onTermination = { _ in continuation.finish() }
        }
    }
    
    internal func stop() async {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
   
}

// MARK: - Battery

internal extension Device {
    
    struct Battery: Equatable {
        var level: Float { UIDevice.current.batteryLevel }
        var state: UIDevice.BatteryState { UIDevice.current.batteryState }
    }
    
    // MARK: - Observers
    
    private func observeBatteryState() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
    }
    
    private func observeBatteryLevel() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
    }
    
    // MARK: - API
    
    @objc func batteryLevelDidChange(_ notification: Notification) {
        Device.batterySubject.send(.init()) // ??
    }
    
    @objc func batteryStateDidChange(_ notification: Notification) {
        Device.batterySubject.send(.init()) // ??
    }
    
    // MARK: - PassthroughSubject
    
    private static let batterySubject: PassthroughSubject<Device.Battery, Never> = .init()
    
}

// MARK: - Static

internal extension Device {
    
    static func model() -> String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    static func id() -> String {
        
        let key = "ios.pawns.sdk.device.installation.identifier"
        
        if let id = UserDefaults.standard.string(forKey: key) {
            return id
        }
        
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: key)
        
        return id
    }
    
}
