import Foundation

internal extension Swift.Optional where Wrapped == String {
    
    func parseJson<T>() -> T? where T:Decodable {
        
        if let str = self, let data = str.data(using: .utf8) {
            let parsed: T? = try? JSONDecoder().decode(T.self, from: data)
            return parsed
        }
        
        return nil
    }
    
}
