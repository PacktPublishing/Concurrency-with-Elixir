# Rarebit

Example of Broadway pipelines consuming messages from RabbitMQ.

Installing RabbitMQ via Docker:

```sh
docker pull rabbitmq:3.13.7-management
docker run -p 5672:5672 -p 15672:15672 --name rabbitmq -d rabbitmq:3.13.7-management
```

Sending messages into the `msgs` queue to be consumed by the `Rarebit.Pipelines.Simple` pipeline:

```iex
iex> {:ok, connection} = AMQP.Connection.open()
iex> {:ok, channel} = AMQP.Channel.open(connection)
iex> AMQP.Basic.publish(channel, "", "msgs", "Hello World!")
```

## Execution Times: Processing 60 messages

| Producers Concurrency | Processors Concurrency | Batch Size | Batch Concurrency | Approx. Elapsed Time |
| :-------------------- | :--------------------- | :--------- | :---------------- | :------------------- |
| 1                     | 1                      | 1          | 1                 | 1:40 |
| 2                     | 1                      | 1          | 1                 | 1:32 |
| 2                     | 2                      | 1          | 1                 | 1:04 |
| 2                     | 8                      | 1          | 1                 | 1:00 |
| 2                     | 1                      | 10         | 1                 | 1:02 |
| 2                     | 1                      | 1          | 10                | 1:00 |
| 2                     | 1                      | 10         | 10                | 1:02 |
| 2                     | 8                      | 10         | 10                | 0:08 |
| 2                     | 8                      | 50         | 10                | 0:08 |
| 2                     | 20                     | 10         | 10                | 0:04 |
| 10                    | 20                     | 50         | 10                | 0:08 |
| 50                    | 50                     | 50         | 50                | 0:06 |
| 4                     | 8                      | 50         | 10                | 0:08 |
| 4                     | 20                     | 50         | 50                | 0:04 |
| 4                     | 50                     | 50         | 50                | 0:06 |

## Questions

What happens if you publish a message to a headers queue and no bindings match?

If a message cannot be routed to any queue (for example, because there are no bindings for the exchange it was published to) it is either dropped or returned to the publisher, depending on message attributes the publisher has set.
