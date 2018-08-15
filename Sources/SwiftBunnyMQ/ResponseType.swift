//
//  RPCReply.swift
//  SwiftBunnyMQ
//
//  Created by Antwan van Houdt on 14/08/2018.
//

import CRabbitMQ

public enum ResponseType: UInt32 {
    case none   = 0
    case normal = 1

    case libraryException = 2
    case serverException  = 3

    static func from(reply: amqp_rpc_reply_t) -> ResponseType? {
        let type = ResponseType(rawValue: reply.reply_type.rawValue)
        if type == .serverException {
            let errorCode = reply.reply.id
            if let errorCString = amqp_error_string2(Int32(errorCode)) {
                let str = String(cString: errorCString)
                print("Server Error: \(str)")
            }
        }
        return type
    }
}
