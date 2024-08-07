import Foundation
import os

internal extension Pawns {
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    private static let timestamp = Timestamp()
    
    static func log<T>(named: String, _ object: T?) {
        guard Preferences.isLoggingEnabled else { return }
        if let object = object {
            self.logger.info(
                "[\(self.timestamp.date, privacy: .public)] 💜 Pawns \(named): \(String(describing: object), privacy: .public)"
            )
        }
    }
    
    static func log(named: String) {
        guard Preferences.isLoggingEnabled else { return }
        self.logger.info(
            "[\(self.timestamp.date, privacy: .public)] 💜 Pawns \(named)"
        )
    }
    
}
