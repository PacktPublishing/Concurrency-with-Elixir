defmodule MyPipeline do
  use Broadway
  require Logger
  @queue "my_queue"
  @exchange "my_exchange"
  @queue_dlx "my_queue.dlx"
  @exchange_dlx "my_exchange.dlx"

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           on_failure: :reject,
           queue: @queue,
           declare: [
             durable: true,
             arguments: [
               {"x-dead-letter-exchange", :longstr, @exchange_dlx},
               {"x-dead-letter-routing-key", :longstr, @queue_dlx}
             ]
           ],
           bindings: [{@exchange, []}],
           after_connect: &declare_rabbitmq_topology/1},
        concurrency: 2
      ],
      processors: [default: [concurrency: 4]]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    # Raising errors or returning a "failed" message here sends the message to the
    # dead-letter queue, e.g.
    Logger.debug("Failing message; this should republish to the dead-letter exchange")

    Broadway.Message.failed(
      message,
      "Failing a message triggers republication to the dead-letter exchange"
    )
  end

  defp declare_rabbitmq_topology(channel) do
    IO.puts("Defining topology in #{__MODULE__}")

    with :ok <- AMQP.Exchange.declare(channel, "my_exchange", :fanout) do
      # AMQP.Queue.declare(channel, @queue)
      :ok
    end
  end
end
