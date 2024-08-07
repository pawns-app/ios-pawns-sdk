import Foundation

internal extension Optional where Wrapped == Task<Void, Never> {
    
    mutating func destroy() {
        self?.cancel()
        self = nil
    }
    
}
