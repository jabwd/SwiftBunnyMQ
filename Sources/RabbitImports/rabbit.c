//
//  rabbit.c
//  SwiftBunnyMQ
//
//  Created by Antwan van Houdt on 13/08/2018.
//

#include "rabbit.h"

amqp_rpc_reply_t mq_login(const char *username, const char *password, amqp_connection_state_t connection) {
    return amqp_login(connection, "/", 0, 131072, 0, AMQP_SASL_METHOD_PLAIN, username, password);
}

void mq_bind(amqp_connection_state_t connection, uint16_t channel, const char *queue, const char *exchange, const char *bindingKey, amqp_table_t table) {
    amqp_bytes_t queueBytes = amqp_cstring_bytes(queue);
    amqp_bytes_t exchangeBytes = amqp_cstring_bytes(exchange);
    amqp_bytes_t bindingKeyBytes = amqp_cstring_bytes(bindingKey);
    amqp_queue_bind(connection, channel, queueBytes, exchangeBytes, bindingKeyBytes, table);
}

void mq_publish(amqp_connection_state_t connection, uint16_t channel, const char *exchange, const char *routingKey, amqp_boolean_t mandatory, amqp_boolean_t immediate, amqp_basic_properties_t *properties, amqp_bytes_t body) {
    amqp_bytes_t exchangeBytes = amqp_cstring_bytes(exchange);
    amqp_bytes_t routingBytes  = amqp_cstring_bytes(routingKey);
    amqp_basic_publish(
                       connection,
                       channel,
                       exchangeBytes,
                       routingBytes,
                       mandatory,
                       immediate,
                       properties,
                       body
                       );
}
