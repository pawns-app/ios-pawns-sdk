import Foundation

internal extension Pawns {
    
    struct Event: Codable {
        let name: String
        let parameters: Pawns.Event.Parameters
    }
    
}

internal extension Pawns.Event {
    
    struct Parameters: Codable {
        let error: String?
        let bytes_written: String?
    }
    
}
