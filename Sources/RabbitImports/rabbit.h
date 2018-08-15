//
//  rabbit.h
//  SwiftBunnyMQ
//
//  Created by Antwan van Houdt on 13/08/2018.
//

#ifndef rabbit_h
#define rabbit_h

#include <amqp.h>
#include <amqp_tcp_socket.h>

amqp_rpc_reply_t mq_login(const char *username, const char *password, amqp_connection_state_t connection);
void mq_bind(amqp_connection_state_t connection, uint16_t channel, const char *queue, const char *exchange, const char *bindingKey, amqp_table_t table);

void mq_publish(amqp_connection_state_t connection, uint16_t channel, const char *exchange, const char *routingKey, amqp_boolean_t mandatory, amqp_boolean_t immediate, amqp_basic_properties_t *properties, amqp_bytes_t body);

#include <stdio.h>

#endif /* rabbit_h */
