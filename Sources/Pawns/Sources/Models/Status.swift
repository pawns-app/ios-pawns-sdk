import Foundation

public extension Pawns {
    
    public enum Status: Equatable {
        
        case unknown
        case starting
        case reconnecting
        case running
        case notRunning(Reason)
        
        init?(rawValue: Pawns.Event) {
            switch rawValue.name {
            case "starting":
                self = .starting
            case "reconnecting":
                self = .reconnecting
            case "running":
                self = .running
            case "not_running":
                if let reason = Reason(rawValue: rawValue) {
                    self = .notRunning(reason)
                } else {
                    self = .notRunning(.unknown)
                }
            default:
                self = .unknown
            }
        }
        
    }
 
}
