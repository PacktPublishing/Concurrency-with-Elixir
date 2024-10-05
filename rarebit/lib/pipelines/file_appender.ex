defmodule Rarebit.Pipelines.FileAppender do
  @moduledoc """
  A Broadway pipeline that appends messages to files

  ## Options

  - `name` (usually an atom) a valid name for this process
  - `exchange` (string) the name of the exchange.
  - `alt_exchange_type` one of `:direct`, `:fanout`, `:topic`, `:headers`
  - `alt_exchange` (string) the name of the exchange.
  - `exchange_type` one of `:direct`, `:fanout`, `:topic`, `:headers`
  - `queue` (string) name of the queue to which this Broadway instance should subscribe
  - `output_dir` path to a directory where this pipeline may create directories and files
  """

  use Broadway
  require Logger
  alias Broadway.Message

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    # exchange = Keyword.fetch!(opts, :exchange)
    # exchange_type = Keyword.fetch!(opts, :exchange_type)
    # alt_exchange = Keyword.fetch!(opts, :alt_exchange)
    # alt_exchange_type = Keyword.fetch!(opts, :alt_exchange_type)
    queue = Keyword.fetch!(opts, :queue)
    # bindings = Keyword.fetch!(opts, :bindings)

    output_dir = Keyword.fetch!(opts, :output_dir)

    File.mkdir_p!(output_dir)

    # Number of connections to RabbitMQ
    producer_concurrency = 2
    # Number of handle_message processes
    processor_concurrency = 10
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
        a: [batch_size: batch_size, batch_timeout: 1500, concurrency: batch_concurrency],
        b: [batch_size: batch_size, batch_timeout: 1500, concurrency: batch_concurrency],
        c: [batch_size: batch_size, batch_timeout: 1500, concurrency: batch_concurrency]
      ],
      context: %{output_dir: output_dir}
    )
  end

  @batcher_map %{"A" => :a, "B" => :b, "C" => :c}
  @impl true
  def handle_message(_, %Message{data: payload} = message, _) do
    case Map.fetch(@batcher_map, String.first(payload)) do
      {:ok, batcher} ->
        Message.put_batcher(message, batcher)

      :error ->
        Logger.error("First character must be A, B, or C")
        raise "First character must be A, B, or C"
        # Message.failed(message, "First character must be A, B, or C")
    end
  end

  @impl true
  def handle_batch(batcher, messages, _, %{output_dir: output_dir}) do
    lines = Enum.map_join(messages, "\n", & &1.data)
    File.write("#{output_dir}/#{batcher}.log", lines <> "\n", [:utf8, :append])
    messages
  end
end
