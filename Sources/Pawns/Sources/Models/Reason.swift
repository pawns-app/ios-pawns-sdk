import Foundation

public extension Pawns.Status {
    
    public enum Reason: Equatable {
        
        case stopped
        case unknown
        case ipUsed
        case unauthorized
        case nonResidentialIp
        case cantGetFreePort
        case cantOpenPort
        case couldNotMarkPeerAlive
        case connectionFailed
        case waitingForWifi
        case lowBattery
        case unsupportedVersion
        case detectedVPN
        
        init?(rawValue: Pawns.Event) {
            switch rawValue.parameters.error {
            case "ip_used":
                self = .ipUsed
            case "unauthorized":
                self = .unauthorized
            case "non_residential_ip":
                self = .nonResidentialIp
            case "cant_get_free_port":
                self = .cantGetFreePort
            case "cant_open_port":
                self = .cantOpenPort
            case "could_not_mark_peer_alive":
                self = .couldNotMarkPeerAlive
            case "error_connection_failed":
                self = .connectionFailed
            case "error_waiting_for_wifi":
                self = .waitingForWifi
            case "error_low_battery":
                self = .lowBattery
            case "unsupported_version":
                self = .unsupportedVersion
            default:
                self = .unknown
            }
        }
        
        public var isCritical: Bool {
            [
                Self.nonResidentialIp,
                Self.unsupportedVersion,
                Self.unauthorized,
                Self.cantGetFreePort,
                Self.cantOpenPort,
                Self.lowBattery,
                Self.couldNotMarkPeerAlive,
                Self.connectionFailed,
                Self.detectedVPN
            ]
            .contains(self)
        }
        
    }

}
