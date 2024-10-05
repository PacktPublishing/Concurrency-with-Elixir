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
        module: {
          BroadwayRabbitMQ.Producer,
          on_failure: :reject,
          after_connect: &declare_rabbitmq_topology/1,
          queue: @queue,
          declare: [
            durable: true,
            arguments: [
              {"x-dead-letter-exchange", :longstr, @exchange_dlx},
              {"x-dead-letter-routing-key", :longstr, @queue_dlx}
            ]
          ],
          bindings: [{@exchange, []}]
        },
        concurrency: 2
      ],
      processors: [default: [concurrency: 4]]
    )
  end

  defp declare_rabbitmq_topology(amqp_channel) do
    with :ok <- AMQP.Exchange.declare(amqp_channel, @exchange, :fanout, durable: true),
         :ok <- AMQP.Exchange.declare(amqp_channel, @exchange_dlx, :fanout, durable: true),
         {:ok, _} <- AMQP.Queue.declare(amqp_channel, @queue_dlx, durable: true),
         :ok <- AMQP.Queue.bind(amqp_channel, @queue_dlx, @exchange_dlx) do
      :ok
    end
  end

  @impl true
  def handle_message(_processor, message, _context) do
    Logger.error("Big problems in myPipeline")
    # Raising errors or returning a "failed" message here sends the message to the
    # dead-letter queue.
    # You can fail a message
    Broadway.Message.failed(message, "there was a problem")
    # Or you can raise an exception
    raise "Big problems!!"
  end
end
