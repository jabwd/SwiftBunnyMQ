//
//  Socket.swift
//  RabbitImports
//
//  Created by Antwan van Houdt on 14/08/2018.
//

import CRabbitMQ
import RabbitImports

public final class Socket {

    public let connection: amqp_connection_state_t
    public let socket: OpaquePointer

    init?(hostname: String = "localhost", port: Int32 = 5672) {
        connection = amqp_new_connection()
        socket = amqp_tcp_socket_new(connection)
        guard amqp_socket_open(socket, hostname, port) == 0 else {
            amqp_destroy_connection(connection)
            return nil
        }
    }

    deinit {
        amqp_connection_close(connection, AMQP_REPLY_SUCCESS)
        amqp_destroy_connection(connection)
    }

    public func openChannel(id: UInt16) -> ResponseType? {
        amqp_channel_open(connection, id)
        return getReply()
    }
    
    @discardableResult
    public func closeChannel(id: UInt16) -> ResponseType? {
        return ResponseType.from(reply: amqp_channel_close(connection, id, AMQP_REPLY_SUCCESS))
    }

    public func login(username: String = "guest", password: String = "guest") throws {
        let reply = mq_login(username, password, connection)
        guard let response = ResponseType(rawValue: reply.reply_type.rawValue) else {
            print("Unknown response type")
            throw BunnyError.loginFailed
        }
        guard response == .normal else {
            print("Response: \(response)")
            throw BunnyError.loginFailed
        }
    }

    public func getReply() -> ResponseType? {
        return ResponseType.from(reply: amqp_get_rpc_reply(connection))
    }
}
