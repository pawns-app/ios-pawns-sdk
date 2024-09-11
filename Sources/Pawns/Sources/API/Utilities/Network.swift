import Foundation
import Network
import Combine

internal class Network {
    
    private var pathMonitor: NWPathMonitor?
    private var status: Network.Status = .undefined
    
    internal init() {
        self.pathMonitor = .init()
    }
    
    // MARK: - Status
    
    internal enum Status {
        case undefined
        case unsatisfied
        case detectedVPNInterfaceType
        case missingInterfaceType
        case satisfied
    }
    
    // MARK: - API
    
    internal func start() async -> AsyncStream<Network.Status> {
        
        if self.pathMonitor != nil {
            await self.stop()
        }
        
        self.pathMonitor = .init()
        
        return AsyncStream { [unowned self] continuation in
            
            self.pathMonitor?.pathUpdateHandler = { path in
                                
                if self.isVPNConnected() {
                    continuation.yield(.detectedVPNInterfaceType); return
                }
                
                guard path.status == .satisfied else {
                    continuation.yield(.unsatisfied); return
                }
                
                guard Pawns.Preferences.useWifiOnly else {
                    continuation.yield(.satisfied); return
                }
                
                let status: Network.Status = path.usesInterfaceType(.wifi)
                    ? .satisfied
                    : .missingInterfaceType
                
                continuation.yield(status)
            }
            
            continuation.onTermination = { [unowned self] _ in
                self.pathMonitor?.cancel()
                continuation.finish()
            }
            
            self.pathMonitor?.start(queue: DispatchQueue(label: "NSPathMonitor.paths"))
        }
    }
    
    internal func stop() async {
        self.pathMonitor?.cancel()
        self.pathMonitor = nil
    }
    
    // MARK: - VPN
    
    private func isVPNConnected() -> Bool {
        
        let cfDict = CFNetworkCopySystemProxySettings()
        let nsDict = cfDict?.takeRetainedValue() as NSDictionary?
        let keys = nsDict?["__SCOPED__"] as? NSDictionary
        
        for key: String in keys?.allKeys as? [String] ?? [] {
            if (key.contains("tap") || key.contains("tun") || key.contains("ppp") || key.contains("ipsec") || key.contains("utun")) {
                return true
            }
        }
        
        return false
    }
    
}
