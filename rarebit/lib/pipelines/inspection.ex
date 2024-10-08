defmodule Rarebit.Pipelines.Inspection do
  @moduledoc """
  A Broadway pipeline that collects messages and logs the to a file (inspection.log
  in the the configured output_dir).

  This is useful for inspecting queues.

  ## Options

  - `name` (usually an atom) a valid name for this process
  - `queue` (string) name of the queue to which this Broadway instance should subscribe
  - `output_dir` path to a directory where this pipeline may create directories and files
  """

  use Broadway
  require Logger
  alias Broadway.Message

  # Avoids the need to wrap children in `Supervisor.child_spec/2`
  def child_spec(args), do: %{id: args[:name], start: {__MODULE__, :start_link, [args]}}

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    queue = Keyword.fetch!(opts, :queue)

    output_dir = Keyword.fetch!(opts, :output_dir)

    File.mkdir_p!(output_dir)

    # Number of connections to RabbitMQ
    producer_concurrency = 2
    # Number of handle_message processes
    processor_concurrency = 4
    # ~ size of each batch
    batch_size = 50
    # Number of batch processes
    batch_concurrency = 1

    Broadway.start_link(__MODULE__,
      name: name,
      producer: [
        module: {
          BroadwayRabbitMQ.Producer,
          queue: queue,
          qos: [
            prefetch_count: 50
          ],
          on_failure: :reject
        },
        concurrency: producer_concurrency
      ],
      processors: [
        default: [concurrency: processor_concurrency]
      ],
      batchers: [
        default: [batch_size: batch_size, batch_timeout: 1500, concurrency: batch_concurrency]
      ],
      context: %{output_dir: output_dir, queue: queue}
    )
  end

  @impl true
  def handle_message(_, %Message{data: data} = message, %{queue: queue}) do
    Logger.debug("Receiving message for inspection on queue #{queue}: #{inspect(data)}")
    message
  end

  @impl true
  def handle_batch(:default, messages, _, %{output_dir: output_dir}) do
    lines = Enum.map_join(messages, "\n", & &1.data)
    File.write("#{output_dir}/inspection.log", lines <> "\n", [:utf8, :append])
    messages
  end
end
