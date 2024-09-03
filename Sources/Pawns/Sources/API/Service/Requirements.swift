import Foundation
import Combine

internal extension Pawns {
    
    internal class Requirements: NSObject {
        
        internal override init() { }
        
        // MARK: - Reason
        
        enum Reason: Equatable {
            
            case network(Network)
            case battery(Battery)
            case satisfied
            
            enum Network {
                case missingInterfaceType
                case wrongInterfaceType
            }
            
            enum Battery {
                case lowBattery
            }
            
        }
        
        private var networkReason: Reason? = nil
        private var batteryReason: Reason? = nil
        
        // MARK: - Services
        
        private var device: Device = .init()
        private let network: Network = .init()
        
        // MARK: - Requirements
        
        internal func monitorRequirements() async -> AsyncStream<Reason> {
            AsyncStream { [unowned self] continuation in
                
                Task {
                    
                    await withTaskGroup(of: Void.self) { group in

                        group.addTask {
                            await self.observeNetworkStatus {
                                self.networkReason = $0
                                self.onReasonsChange(continuation: continuation)
                            }
                        }
                        
                        group.addTask {
                            await self.observeBatteryStatus {
                                self.batteryReason = $0
                                self.onReasonsChange(continuation: continuation)
                            }
                        }

                        continuation.onTermination = { _ in continuation.finish() }
                    }
                }
            }
        }
        
        private func onReasonsChange(continuation: AsyncStream<Reason>.Continuation) {
            
            var reasons: [Reason?] = [
                self.networkReason,
                self.batteryReason,
            ]
            
            var allReasonsReceived = reasons.allSatisfy { $0 != nil }
            var allReasonsSatisfied: Bool = reasons.allSatisfy { $0 == .satisfied }
            
            guard allReasonsReceived else { return }
            
            if allReasonsSatisfied {
                continuation.yield(.satisfied)
            } else if let reason = reasons.compactMap { $0 }.first { $0 != .satisfied } {
                continuation.yield(reason)
            }
        }
        
    }
 
}

// MARK: - Observers

private extension Pawns.Requirements {
    
    func observeNetworkStatus(_ callback: @escaping (Reason) -> Void) async {
        for await status in await self.network.start() {
            switch status {
            case .unsatisfied:
                callback(.network(.missingInterfaceType))
                
            case .missingInterfaceType:
                callback(.network(.wrongInterfaceType))
                
            case .satisfied:
                callback(.satisfied)
                
            default:
                break
            }
        }
    }
    
    func observeBatteryStatus(_ callback: @escaping (Reason) -> Void) async {
        for await battery in await self.device.start() {
            
            let isLowBattery = battery.level <= 0.20 && battery.state != .charging

            if Pawns.Preferences.useLowPowerMode {
                callback(isLowBattery ? .battery(.lowBattery) : .satisfied)
            } else {
                callback(.satisfied)
            }
        }
    }
    
}

// MARK: - Peer Service Status

internal extension Pawns.Requirements.Reason.Network {
    
    var serviceStatus: Pawns.Status? {
        switch self {
        case .missingInterfaceType:
            return .notRunning(.connectionFailed)
        case .wrongInterfaceType:
            return .notRunning(.waitingForWifi)
        default:
            return nil
        }
    }
    
}

internal extension Pawns.Requirements.Reason.Battery {
    
    var serviceStatus: Pawns.Status? {
        switch self {
        case .lowBattery:
            return .notRunning(.lowBattery)
        default:
            return nil
        }
    }
    
}
