import Foundation
import SwiftGRPC

class Server {
    static let shared = Server()
    
    private(set) var port = "5000"
    
    private(set) var server: ServiceServer?
    
    var controller: GameViewController?
    
    var player: PlayerTurn = .none
    
    private(set) var gameProvider = CCGameProvider()
    
    private init() {}
    
    @discardableResult
    func setPort(_ port: String) -> Self {
        self.port = port
        return self
    }
    
    func setProviderController(controller: GameViewController?) {
        if let controller = controller {
            gameProvider.setController(controller: controller)
        }
    }
    
    func start() {
        guard let serverIPAddress = getWiFiAddress() else {
            print("Could not get client IP address")
            return
        }
        server = ServiceServer(address: "\(serverIPAddress):\(port)", serviceProviders: [gameProvider])
        print("Server listening in \(serverIPAddress):\(port)")
        DispatchQueue.global(qos: .background).async {
            self.server?.start()
        }
    }
    
    func stop() {
        self.server?.server.stop()
    }
    
    deinit {
        self.stop()
    }
    
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
}