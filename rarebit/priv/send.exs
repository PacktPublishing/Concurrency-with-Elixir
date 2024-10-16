# From https://github.com/dashbitco/broadway_bike_sharing_rabbitmq_example
{:ok, connection} = AMQP.Connection.open
{:ok, channel} = AMQP.Channel.open(connection)
AMQP.Queue.declare(channel, "my_queue")
AMQP.Basic.publish(channel, "", "my_queue", "Hello World!")
IO.puts " [x] Sent message"
AMQP.Connection.close(connection)
