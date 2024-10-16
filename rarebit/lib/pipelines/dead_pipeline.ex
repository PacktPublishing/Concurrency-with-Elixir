defmodule DeadPipeline do
  use Broadway
  require Logger

  @queue_dlx "my_queue.dlx"
  @exchange_dlx "my_exchange.dlx"

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           on_failure: :reject,
           queue: @queue_dlx,
           declare: [
             durable: true
           ],
           after_connect: &declare_rabbitmq_topology/1},
        concurrency: 2
      ],
      processors: [default: [concurrency: 4]]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    Logger.debug("Dead letter message received!")
    message
  end

  defp declare_rabbitmq_topology(channel) do
    IO.puts("Defining topology in #{__MODULE__}")

    with :ok <- AMQP.Exchange.declare(channel, @exchange_dlx, :fanout) do
      # AMQP.Queue.declare(channel, @queue_dlx)
      :ok
    end
  end
end
