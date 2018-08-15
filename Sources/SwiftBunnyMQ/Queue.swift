import CRabbitMQ
import RabbitImports

let hostname: String = "localhost"
let port: Int32      = 5672

final class Queue {

    let socket: Socket
    let name: String

    private let channelID: UInt16

    init(socket: Socket, name: String, channelID: UInt16 = 1) throws {
        self.socket    = socket
        self.name      = name
        self.channelID = channelID

        guard socket.openChannel(id: channelID) == .normal else {
            throw BunnyError.channelOpenFailed
        }
        let result = self.declareQueue()
        guard result == .normal else {
            print("Result: \(String(describing: result))")
            throw BunnyError.queueDeclarationFailed
        }
    }

    deinit {
        socket.closeChannel(id: channelID)
    }

    public func bindQueue(exchange: String, routingKey: String) -> ResponseType? {
        mq_bind(socket.connection, channelID, name, exchange, routingKey, amqp_empty_table)
        return socket.getReply()
    }

    public func declareQueue() -> ResponseType? {
        let queueName = amqp_cstring_bytes(name)
        amqp_queue_declare(
            socket.connection,
            channelID,
            queueName,
            0, // Passive
            0, // Durable
            0, // Exclusive
            0, // Auto-delete
            amqp_empty_table
        )
        return socket.getReply()
    }

    public func run() throws {
        amqp_basic_consume(
            socket.connection,
            channelID,
            amqp_cstring_bytes(name),
            amqp_empty_bytes,
            0,
            0,
            0,
            amqp_empty_table
        )
        guard socket.getReply() == .normal else {
            throw BunnyError.consumingFailed
        }

        while( true ) {
            amqp_maybe_release_buffers(socket.connection)

            var envelope: amqp_envelope_t = amqp_envelope_t()
            let ret = amqp_consume_message(socket.connection, &envelope, nil, 0)

            let response = ResponseType.from(reply: ret)
            guard response == .normal else {
                amqp_destroy_envelope(&envelope)
                throw BunnyError.consumingFailed
            }

            guard let rawPtr = envelope.message.body.bytes else {
                continue
            }
            let typedPointer = rawPtr.bindMemory(to: UInt8.self, capacity: envelope.message.body.len)
            let bufferPtr = UnsafeMutableBufferPointer(start: typedPointer, count: envelope.message.body.len)
            var buffer: [UInt8] = Array(bufferPtr)
            let str = String(cString: &buffer)
            print("Envelope string: \(str)")

            amqp_basic_ack(socket.connection, 1, envelope.delivery_tag, 1)
            amqp_destroy_envelope(&envelope)
            break
        }
    }
}
