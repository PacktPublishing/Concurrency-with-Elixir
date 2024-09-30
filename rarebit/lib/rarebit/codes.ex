defmodule Rarebit.Codes do
  @moduledoc """
  This module is dedicated to building the message payloads (the "codes") and
  publishing them to the queue for consumption by Broadway.
  """

  @doc """
  Generates a message payload
  The format is a 3-character prefix followed by a colon, followed by a random string.

  ## Examples

      iex> Rarebit.Codes.generate_payload
      "CAC:7b72f63e-afd7-4574-abf5-50d50babe149"
  """
  def payload do
    random_str() <> ":" <> unique_val()
  end

  @doc """
  Calculates headers for the given payload
  """
  def headers(<<prefix::binary-size(3), _rest::binary>> = _payload) do
    freq_vals = prefix |> String.split("", trim: true) |> Enum.frequencies() |> Map.values()

    []
    |> Kernel.++(double_header(freq_vals))
    |> Kernel.++(triple_header(freq_vals))

    # is triple?
    # is double?
    # String.split("CAA", "", trim: true) |> Enum.frequencies() |> Map.values() |> Enum.member?(3)
  end

  defp double_header(freq_vals) do
    if Enum.max(freq_vals) >= 2 do
      [{"double", :binary, "true"}]
    else
      []
    end
  end

  defp triple_header(freq_vals) do
    if Enum.max(freq_vals) >= 3 do
      [{"triple", :binary, "true"}]
    else
      []
    end
  end

  @doc """
  Generates a 3-letter code consisting of the characters A, B, or C randomly
  selected. E.g. "BAC" or "AAB"
  """
  @chars "ABC" |> String.split("", trim: true)
  def random_str do
    1..3
    |> Enum.reduce([], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end

  @doc """
  Generates a unique string (or unique enough for our purposes).
  """
  def unique_val, do: UUID.uuid4()

  @doc """
  Publishes multiple messages to the given exchange using the given routing key.

  ## Examples

      iex> Rarebit.Codes.publish_multiple("", "msgs", 60)
  """
  def publish_multiple(exchange, routing_key, n \\ 50) do
    with {:ok, connection} <- AMQP.Connection.open(Application.get_env(:amqp, :connections)),
         {:ok, channel} <- AMQP.Channel.open(connection) do
      Enum.each(1..n, fn _ ->
        payload = payload()
        headers = headers(payload)
        AMQP.Basic.publish(channel, exchange, routing_key, payload, headers: headers)
      end)
    end
  end
end
