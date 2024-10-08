defmodule Rarebit do
  @moduledoc """
  Rarebit is an instructional example of using Broadway with RabbitMQ.
  Interactions with RabbitMQ are wrapped in a GenServer.  Events are logged for
  visibility.
  """
  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(
      __MODULE__,
      Application.fetch_env!(:amqp, :connections),
      name: __MODULE__
    )
  end

  @doc """
  Helper function to publish a message to the given exchange / routing_key with
  the given headers.

  ## Examples

  Send a normal message sent with proper headers that describes the message content:
      iex> Rarebit.publish("headers_exchange", "", "ABC-example", headers: [{"pangram", :longstr, "true"}])

  Send a message without proper headers. The exchange can't route it, so it gets sent to the
  alternate exchange. Think of it like a 404.
      iex> Rarebit.publish("headers_exchange", "", "ABC-no-headers")

  Send a message with a bad payload. The message can be routed because it has proper headers,
  but Broadway will reject the message because it has a bad payload.
      iex> Rarebit.publish("headers_exchange", "", "EFG-invalid-payload", headers: [{"pangram", :longstr, "true"}])

  Send a message directly to a queue via the direct exchange.
      iex> Rarebit.publish("", "triples", "ABC sent directly to a queue via the direct exchange")

  Send a message to the fallback_exchange, which fans the messages out to all bound queues.
      iex> Rarebit.publish("fallback_exchange", "", "fanout?")
  """
  def publish(exchange, routing_key, payload, opts \\ []) do
    GenServer.call(__MODULE__, {:publish, exchange, routing_key, payload, opts})
  end

  @doc """
  Publishes multiple messages with codes to the given exchange using the given routing key.
  This function is used fill up queues so we can observe how Broadway drains them

  ## Examples

      iex> Rarebit.publish_codes("", "msgs", 60)
      iex> Rarebit.publish_codes("headers_exchange", "", 100)
  """
  def publish_codes(exchange, routing_key, n \\ 50) do
    Enum.each(1..n, fn _ ->
      payload = Rarebit.Codes.payload()
      headers = Rarebit.Codes.headers(payload)
      GenServer.call(__MODULE__, {:publish, exchange, routing_key, payload, headers: headers})
    end)
  end

  @impl true
  def init(config) do
    with {:ok, connection} <- AMQP.Connection.open(config),
         {:ok, channel} <- AMQP.Channel.open(connection) do
      {:ok, %{channel: channel}}
    end
  end

  @impl true
  def handle_call(
        {:publish, exchange, routing_key, payload, opts},
        _from,
        %{channel: channel} = state
      ) do
    immutable_opts = [
      app_id: "rarebit",
      timestamp: DateTime.to_unix(DateTime.utc_now())
    ]

    opts = Keyword.merge(opts, immutable_opts)
    Logger.debug("Publishing message '#{payload}' with opts #{inspect(opts)}")
    {:reply, AMQP.Basic.publish(channel, exchange, routing_key, payload, opts), state}
  end
end
