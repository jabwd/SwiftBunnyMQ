import XCTest
@testable import SwiftBunnyMQ

final class SwiftBunnyMQTests: XCTestCase {
    func testQueue() {
        if let socket = Socket() {
            do {
                try socket.login()
                /*let queue = try Queue(socket: socket, name: "user:1")
                let result = queue.bindQueue(exchange: "chatmessages-direct", routingKey: "user:1")
                XCTAssert(result == .normal, "Bind queue failed \(String(describing: result))")
                try queue.run()*/
                let producer = try Producer(socket: socket, channelID: 2)
                let test: [UInt8] = Array("Hello World!".utf8)
                producer.publish(bytes: test, exchange: "chatmessages-direct", routingKey: "user:1", persistent: true)
            } catch {
                XCTAssert(false, "Error \(error)")
            }
        } else {
            XCTAssert(false, "Unable to create socket")
        }
    }


    static var allTests = [
        ("testQueue", testQueue),
    ]
}
