defmodule Rarebit.Application do
  @moduledoc "Set up the Rarebit supervision tree and prepare the RabbitMQ topology"

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    :ok = declare_rabbitmq_topology()

    # {:ok, connection} = AMQP.Connection.open()
    # {:ok, channel} = AMQP.Channel.open(connection)

    # # Declare exchanges
    # :ok = AMQP.Exchange.declare(channel, "my_exchange", :fanout, durable: true)
    # :ok = AMQP.Exchange.declare(channel, "my_exchange.dlx", :fanout, durable: true)

    # # Define and bind queues within the exchange depending on your needs
    # {:ok, _} = AMQP.Queue.declare(channel, "my_queue.dlx", durable: true)
    # :ok = AMQP.Queue.bind(channel, "my_queue.dlx", "my_exchange.dlx", [])

    # {:ok, _} =
    #   AMQP.Queue.declare(channel, "my_queue",
    #     durable: true,
    #     arguments: [
    #       {"x-dead-letter-exchange", :longstr, "my_exchange.dlx"},
    #       {"x-dead-letter-routing-key", :longstr, "my_queue.dlx"}
    #     ]
    #   )

    # :ok = AMQP.Queue.bind(channel, "my_queue", "my_exchange", [])

    children = [
      Rarebit,
      # Broadway pipelines
      Rarebit.Pipelines.Simple,
      # Supervisor.child_spec(
      {Rarebit.Pipelines.FileAppender,
       [name: :doubles, queue: "doubles", output_dir: "tmp/doubles"]},
      #   id: :doubles
      # ),
      # Supervisor.child_spec(
      {Rarebit.Pipelines.FileAppender,
       [name: :triples, queue: "triples", output_dir: "tmp/triples"]},
      #   id: :triples
      # ),
      # Supervisor.child_spec(
      {Rarebit.Pipelines.FileAppender,
       [name: :pangrams, queue: "pangrams", output_dir: "tmp/pangrams"]},
      #   id: :pangrams
      # ),
      {Rarebit.Pipelines.Inspection, [queue: "misfits", output_dir: "tmp/misfits"]},

      # MyPipeline,
      # DeadPipeline,
      # {Rarebit.Pipelines.FileAppender,
      #  [
      #    name: :doubles,
      #    queue: "doubles",
      #    output_dir: "tmp/doubles"
      #  ]},
      # {Rarebit.Pipelines.FileAppender,
      #  [
      #    name: :triples,
      #    queue: "triples",
      #    output_dir: "tmp/triples"
      #  ]},
      # {Rarebit.Pipelines.FileAppender,
      #  [
      #    name: :pangrams,
      #    queue: "pangrams",
      #    output_dir: "tmp/pangrams"
      #  ]},

      # Standard Phoenix stuff below...
      RarebitWeb.Telemetry,
      Rarebit.Repo,
      {DNSCluster, query: Application.get_env(:rarebit, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Rarebit.PubSub},
      # Start to serve requests, typically the last entry
      RarebitWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rarebit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RarebitWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @doc """
  Explicitly setup our exchanges and queues -- this can be organized into further
  functions, but it is done here mostly long-form to make it easier to see the syntax
  """
  def declare_rabbitmq_topology do
    Logger.info("Setting up RabbitMQ Topology...")
    primary_exchange = "headers_exchange"
    alt_exchange = "fallback_exchange"

    # These headers are part of the queue bindings
    dead_letter_headers = [
      {"x-dead-letter-exchange", :longstr, alt_exchange},
      {"x-dead-letter-routing-key", :longstr, ""}
    ]

    {:ok, connection} = AMQP.Connection.open(Application.get_env(:amqp, :connections))
    {:ok, channel} = AMQP.Channel.open(connection)

    # Setup the alternate exchange
    :ok = AMQP.Exchange.declare(channel, alt_exchange, :fanout, durable: true)

    # Setup the primary exchange
    :ok =
      AMQP.Exchange.declare(channel, primary_exchange, :headers,
        durable: true,
        arguments: [{"alternate-exchange", :longstr, alt_exchange}]
      )

    # Queue(s) in the alternate queue
    setup_bound_queue(channel, "misfits", alt_exchange, durable: true)

    # Queues in the primary exchange
    setup_bound_queue(
      channel,
      "doubles",
      primary_exchange,
      [durable: true, arguments: dead_letter_headers],
      arguments: [{"double", :longstr, "true"}, {"x-match", :longstr, "all"}]
    )

    setup_bound_queue(
      channel,
      "triples",
      primary_exchange,
      [durable: true, arguments: dead_letter_headers],
      arguments: [{"triple", :longstr, "true"}, {"x-match", :longstr, "all"}]
    )

    setup_bound_queue(
      channel,
      "pangrams",
      primary_exchange,
      [durable: true, arguments: dead_letter_headers],
      arguments: [{"pangram", :longstr, "true"}, {"x-match", :longstr, "all"}]
    )
  end

  @doc """
  Declares a queue within an exchange and binds the queue to that exchange
  with the options provided.
  """
  def setup_bound_queue(channel, queue, exchange, q_opts, bind_opts \\ []) do
    {:ok, _} = AMQP.Queue.declare(channel, queue, q_opts)
    :ok = AMQP.Queue.bind(channel, queue, exchange, bind_opts)
  end
end
