defmodule Rarebit do
  @moduledoc """
  Rarebit is an example of using Broadway with RabbitMQ
  """
  require Logger

  @doc """
  Helper function to publish a message to the given exchange / routing_key with
  the given headers.

  ## Examples

  Send a normal message sent with a header that properly describes the message content:
      iex> Rarebit.publish("headers_exchange", "", "ABC-example", headers: [{"pangram", :longstr, "true"}])

  Send a message without proper headers. The exchange can't route it, so it gets sent to the
  alternate exchange. Think of it like a 404.
      iex> Rarebit.publish("headers_exchange", "", "ABC-no-headers")

  Send a message with a bad payload. The message can be routed because it has proper headers,
  but Broadway will reject the message because it has a bad payload.
      iex> Rarebit.publish("headers_exchange", "", "EFG-invalid-payload", headers: [{"pangram", :longstr, "true"}])

  Send a message directly to a queue via the direct exchange.
      iex> Rarebit.publish("", "triples", "ABC sent directly to a queue via the direct exchange")

      iex> Rarebit.publish("", "my_queue", "dead-letter?")
      iex> Rarebit.publish("alternate_exchage", "", "fanout?")
  """
  def publish(exchange, routing_key, payload, opts \\ []) do
    with {:ok, connection} <- AMQP.Connection.open(Application.get_env(:amqp, :connections)),
         {:ok, channel} <- AMQP.Channel.open(connection) do
      AMQP.Basic.publish(channel, exchange, routing_key, payload, opts)
    end
  end

  @doc """
  Publishes multiple messages with codes to the given exchange using the given routing key.
  This function is used fill up queues so we can observe how Broadway drains them

  ## Examples

      iex> Rarebit.publish_codes("", "msgs", 60)
      iex> Rarebit.publish_codes("headers_exchange", "", 100)
  """
  def publish_codes(exchange, routing_key, n \\ 50) do
    with {:ok, connection} <- AMQP.Connection.open(Application.get_env(:amqp, :connections)),
         {:ok, channel} <- AMQP.Channel.open(connection) do
      Enum.each(1..n, fn _ ->
        payload = Rarebit.Codes.payload()
        headers = Rarebit.Codes.headers(payload)
        Logger.debug("Publishing message #{payload} headers #{inspect(headers)}")
        AMQP.Basic.publish(channel, exchange, routing_key, payload, headers: headers)
      end)
    end
  end
end
