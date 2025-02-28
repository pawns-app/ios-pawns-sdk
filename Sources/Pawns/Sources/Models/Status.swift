import Foundation

public extension Pawns {
    
    public enum Status: Equatable {
        
        case unknown
        case starting
        case reconnecting
        case running(trafic: Int)
        case notRunning(Reason)
        
        init?(rawValue: Pawns.Event) {
            switch rawValue.name {
            case "starting":
                self = .starting
            case "reconnecting":
                self = .reconnecting
            case "running":
                self = .running(trafic: .zero)
            case "traffic":
                if let bytesWritten = rawValue.parameters.bytes_written, let trafic = Int(bytesWritten) {
                    self = .running(trafic: trafic)
                } else {
                    self = .running(trafic: .zero)
                }
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

internal extension Pawns.Status {
    
    var isRunning: Bool {
        if case .running = self {
            return true
        }
        return false
    }
    
}
