import Foundation

internal class Timestamp {
    
    internal lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    internal var date: String { dateFormatter.string(from: Date()) }
    
}
