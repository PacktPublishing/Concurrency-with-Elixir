defmodule Rarebit.Pipelines.FileAppender do
  @moduledoc """
  A Broadway pipeline that appends messages to files

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
        concurrency: 2
      ],
      processors: [
        default: [concurrency: 10]
      ],
      batchers: [
        a: [batch_size: 50, batch_timeout: 1500, concurrency: 1],
        b: [batch_size: 50, batch_timeout: 1500, concurrency: 1],
        c: [batch_size: 50, batch_timeout: 1500, concurrency: 1]
      ],
      context: %{output_dir: output_dir, name: name}
    )
  end

  @batcher_map %{"A" => :a, "B" => :b, "C" => :c}
  @impl true
  def handle_message(_, %Message{data: payload} = message, %{name: name}) do
    Logger.debug("Handling message in #{__MODULE__} (#{name}")

    case Map.fetch(@batcher_map, String.first(payload)) do
      {:ok, batcher} ->
        Message.put_batcher(message, batcher)

      :error ->
        Logger.error("First character must be A, B, or C")
        Message.failed(message, "First character must be A, B, or C")
    end
  end

  @impl true
  def handle_batch(batcher, messages, _, %{output_dir: output_dir}) do
    lines = Enum.map_join(messages, "\n", & &1.data)
    File.write("#{output_dir}/#{batcher}.log", lines <> "\n", [:utf8, :append])
    messages
  end
end
