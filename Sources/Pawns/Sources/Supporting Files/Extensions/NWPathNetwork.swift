import Foundation
import Network

internal extension NWPathMonitor {
    
    func paths() -> AsyncStream<NWPath> {
        
        AsyncStream { continuation in
            
            pathUpdateHandler = { path in
                continuation.yield(path)
            }
            
            continuation.onTermination = { _ in
                self.cancel()
                continuation.finish()
            }
            
            start(queue: DispatchQueue(label: "NSPathMonitor.paths"))
        }
    }
    
}
