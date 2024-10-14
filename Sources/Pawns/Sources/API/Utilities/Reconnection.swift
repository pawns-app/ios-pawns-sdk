import Foundation

internal class Reconnection: NSObject {
    
    private var timerTask: Task<(), Never>? = nil
    private static let deadline: UInt64 = 30_000_000_000

    internal override init() { /* - */ }
    
    // MARK: - API
        
    internal func start() async -> AsyncStream<Void> {
        
        Pawns.log(named: "reconnecting in 30 seconds...")
        
        return AsyncStream { [weak self] continuation in
                
            self?.timerTask = Task { [weak self] in
                do {
                    try await Task.sleep(nanoseconds: Reconnection.deadline)
                    guard !Task.isCancelled else { return }
                    continuation.yield(())
                    self?.stop()
                } catch {
                    self?.stop()
                }
            }
            
            continuation.onTermination = { _ in continuation.finish() }
        }
    }
    
    private func stop() {
        guard self.timerTask != nil else { return }
        self.timerTask.destroy()
    }
    
}
