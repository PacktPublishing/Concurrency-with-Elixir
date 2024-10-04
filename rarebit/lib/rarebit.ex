defmodule Rarebit do
  @moduledoc """
  Rarebit is an example of using Broadway with RabbitMQ
  """

  @doc """
  Helper function to publish a message to the given exchange / routing_key with
  the given headers.
  """
  def publish(exchange, routing_key, payload, headers \\ []) do
    with {:ok, connection} <- AMQP.Connection.open(Application.get_env(:amqp, :connections)),
         {:ok, channel} <- AMQP.Channel.open(connection) do
      AMQP.Basic.publish(channel, exchange, routing_key, payload, headers: headers)
    end
  end

  # def publish(exchange, routing_key, n \\ 50) do
  #   with {:ok, connection} <- AMQP.Connection.open(Application.get_env(:amqp, :connections)),
  #        {:ok, channel} <- AMQP.Channel.open(connection) do
  #     Enum.each(1..n, fn _ ->
  #       payload = payload()
  #       headers = headers(payload)
  #       AMQP.Basic.publish(channel, exchange, routing_key, payload, headers: headers)
  #     end)
  #   end
  # end

  @doc """
  Setup our exchanges and queues
  """
  def setup_rabbitmq(exchange, exchange_type, alt_exchange, alt_exchange_type, queues) do
    with {:ok, connection} <- AMQP.Connection.open(Application.get_env(:amqp, :connections)),
         {:ok, channel} <- AMQP.Channel.open(connection),
         :ok <- AMQP.Exchange.declare(channel, alt_exchange, alt_exchange_type),
         :ok <-
           AMQP.Exchange.declare(channel, exchange, exchange_type,
             arguments: [{"alternate-exchange", :longstr, alt_exchange}]
           ) do
      Enum.each(queues, fn {q, opts} ->
        AMQP.Queue.declare(channel, q, durable: true)
        AMQP.Queue.bind(channel, q, exchange, arguments: opts)
      end)

      #  {:ok, _} <- AMQP.Queue.declare(channel, queue) do
      # :ok
      # {:ok, _} <- AMQP.Queue.declare(channel, queue)
      # :ok
    end
  end
end
