//
//  Producer.swift
//  SwiftBunnyMQ
//
//  Created by Antwan van Houdt on 14/08/2018.
//

import RabbitImports

public final class Producer {

    private let socket: Socket
    private let channelID: UInt16

    init(socket: Socket, channelID: UInt16 = 1) throws {
        self.socket    = socket
        self.channelID = channelID

        guard socket.openChannel(id: channelID) == .normal else {
            throw BunnyError.channelOpenFailed
        }
    }

    deinit {
        socket.closeChannel(id: channelID)
    }

    public func publish(bytes: [UInt8], exchange: String, routingKey: String, persistent: Bool) {
        var localBytes = bytes
        let body: amqp_bytes_t = amqp_bytes_t(len: localBytes.count, bytes: &localBytes)
        mq_publish(
            socket.connection,
            channelID,
            exchange,
            routingKey,
            0, // Mandatory or not
            (persistent == true ? 1 : 0),
            nil,
            body
        )
    }
}
