import UIKit
import Foundation
import Combine
import Network
import Mobile_sdk

public class Pawns: NSObject, Mobile_sdkEventCallbackProtocol {
    
    // MARK: - Shared
    
    private static var service: Pawns = .none()
    
    // MARK: - Auth
    
    private let apiKey: String?
    
    // MARK: - Init
    
    private init(apiKey: String?) {
        
        self.apiKey = apiKey
        
        guard apiKey != nil else { return }
        
        Mobile_sdkInitialize(
            Device.id(),
            Device.model()
        )
    }
    
    public static func setup(apiKey: String) {
        
        guard !self.service.isInitialized else {
            Pawns.log(named: "service is already initialized.")
            return
        }
        
        self.service = .init(apiKey: apiKey)
    }
    
    // MARK: - Private
    
    private var isInitialized: Bool = false
    
    private let requirements: Requirements = .init()
    private let reconnection: Reconnection = .init()
    
    private var processTask: Task<(), Never>? = nil
    
    private var isRunning: Bool = false
    private var status: Pawns.Status = .unknown
    
}

// MARK: - API

public extension Pawns {
    
    // MARK: - Public
        
    @discardableResult
    static func start() async -> AsyncStream<Pawns.Status> {
        await self.service.startRoutine()
    }
    
    static func stop() {
        self.service.stopRoutine()
    }
    
    static func status() -> Pawns.Status {
        self.service.status
    }
    
    static func isRunning() -> Bool {
        self.service.isRunning
    }
    
    // MARK: - Private
    
    @discardableResult
    private func startRoutine() async -> AsyncStream<Pawns.Status> {
        
        guard !self.isRunning else {
            return .none()
        }
        
        guard self.apiKey != nil else {
            fatalError("💜 Pawns missing api key.")
        }
        
        return AsyncStream { [unowned self] continuation in
            
            self.processTask = Task {
                
                await withTaskGroup(of: Void.self) { group in
                    
                    group.addTask {
                        await self.onRequirementChange()
                    }

                    group.addTask {
                        await self.onStatusChange(continuation: continuation)
                    }
                }
            }
        }
    }
    
    private func stopRoutine() {
        Mobile_sdkStopMainRoutine()
        Pawns.subject.send(.notRunning(.stopped))
        self.isRunning = false
        self.processTask.destroy()
    }
    
}

// MARK: - OnChange

private extension Pawns {
    
    // MARK: - Private
    
    func onRequirementChange() async {
        for await status in await self.requirements.monitorRequirements() {
            
            Pawns.log(named: "requirements", status)
            
            switch status {
            case .network(let network):
                network.serviceStatus.flatMap(Pawns.subject.send)
                
            case .battery(let battery):
                battery.serviceStatus.flatMap(Pawns.subject.send)
                
            case .satisfied:
                guard !isRunning else { return }
                self.isRunning = true
                Mobile_sdkStartMainRoutine(self.apiKey, self)
            }
        }
    }
    
    func onStatusChange(continuation: AsyncStream<Pawns.Status>.Continuation) async {
        await self.observePawnsStatus { [unowned self] status in
            
            guard self.status != status else { return }

            Pawns.log(named: "service status", status)
            self.status = status
            
            if case let .notRunning(reason) = status {
                if reason.isCritical {
                    Task { await self.onReconnect(continuation: continuation) }
                }
                continuation.yield(status)
            } else {
                continuation.yield(status)
            }
        }
    }
    
    func onReconnect(continuation: AsyncStream<Pawns.Status>.Continuation) async {
        Mobile_sdkStopMainRoutine()
        continuation.yield(.reconnecting)
        for await reconnect in await self.reconnection.start() {
            Mobile_sdkStartMainRoutine(self.apiKey, self)
        }
    }
    
}

// MARK: - Event

public extension Pawns {
    
    func onEvent(_ str: String?) {
        
        let event: Event? = str.parseJson()

        Pawns.log(named: "received raw data", str)

        guard
            let event = event,
            let status = Pawns.Status(rawValue: event)
        else {
            return
        }
        
        Pawns.subject.send(status)
    }
    
    private func observePawnsStatus(_ callback: @escaping (Pawns.Status) -> Void) async {
        for await event in self.statusStream() {
            callback(event)
        }
    }
    
    // MARK: - Status PassthroughSubject
    
    private static let subject: PassthroughSubject<Pawns.Status, Never> = .init()
    
    private func statusStream() -> AsyncStream<Pawns.Status> {
        AsyncStream { continuation in
            
            let cancellable = Pawns.subject.sink {
                continuation.yield($0)
            }
            
            continuation.onTermination = { continuation in
                cancellable.cancel()
            }
        }
    }
    
}

// MARK: - Helpers

private extension Pawns {
    
    static func none() -> Pawns { Pawns(apiKey: nil) }
    
}
