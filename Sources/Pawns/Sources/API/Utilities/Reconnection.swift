import Foundation

internal actor Reconnection: NSObject {
    
    private var timerTask: Task<(), Never>? = nil
    static private let deadline: UInt64 = 30_000_000_000

    internal override init() { /* - */ }
    
    // MARK: - API
        
    internal func start() async -> AsyncStream<Void> {
        
        Pawns.log(named: "reconnecting in 30 seconds...")
        
        return AsyncStream { continuation in
                
            self.timerTask = Task { [self] in
                defer {
                    self.timerTask = nil
                }
                do {
                    await try Task.sleep(nanoseconds: Self.deadline)
                    guard !Task.isCancelled else { return }
                    continuation.yield(())
                    self.stop()
                } catch {
                    self.stop()
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
