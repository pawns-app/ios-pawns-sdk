import Foundation

internal class Reconnection: NSObject {
    
    private var timerTask: Task<(), Never>? = nil
    private let deadline: UInt64 = 30_000_000_000

    internal override init() { /* - */ }
    
    // MARK: - API
        
    internal func start() async -> AsyncStream<Void> {
        
        Pawns.log(named: "reconnecting in 30 seconds...")
        
        return AsyncStream { [unowned self] continuation in
                
            self.timerTask = Task { [unowned self] in
                do {
                    await try Task.sleep(nanoseconds: self.deadline)
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
