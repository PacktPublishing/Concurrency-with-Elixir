defmodule Rarebit.Pipelines.Simple do
  @moduledoc """
  A simple pipeline to familiarize us with Broadway
  """

  use Broadway
  require Logger
  alias Broadway.Message

  def start_link(_opts) do
    queue = "msgs"

    # Number of connections to RabbitMQ
    producer_concurrency = 2
    # Number of handle_message processes
    processor_concurrency = 10
    # ~ size of each batch
    batch_size = 50
    # Number of batch processes
    batch_concurrency = 4

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {
          BroadwayRabbitMQ.Producer,
          queue: queue,
          qos: [
            prefetch_count: 50
          ],
          on_failure: :reject,
          after_connect: &declare_rabbitmq_topology(&1, queue)
        },
        concurrency: producer_concurrency
      ],
      processors: [
        default: [concurrency: processor_concurrency]
      ],
      batchers: [
        default: [batch_size: batch_size, batch_timeout: 1500, concurrency: batch_concurrency]
      ]
    )
  end

  @impl true
  def handle_message(_, %Message{} = message, _) do
    Logger.debug("Handling message")
    # Simulate work
    Process.sleep(1000)
    message
  end

  @impl true
  def handle_batch(:default, messages, _, _) do
    Logger.debug("in default batcher")
    # Simulate work
    Process.sleep(1000)
    messages
  end

  # This important block sets up the necessary RabbitMQ exchanges, something like
  # running database migrations.
  defp declare_rabbitmq_topology(amqp_channel, queue) do
    with {:ok, _} <- AMQP.Queue.declare(amqp_channel, queue, durable: true) do
      :ok
    end
  end
end
