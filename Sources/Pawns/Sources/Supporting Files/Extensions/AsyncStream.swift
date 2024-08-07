import Foundation
import Combine

internal extension AsyncStream where Element == Pawns.Status {
    
    static func `none`() -> Self {
        AsyncStream<Element> { continuation in
            continuation.finish()
        }
    }
    
}
