defmodule Rarebit.Codes do
  @moduledoc """
  This module is dedicated to building the message payloads (the "codes") and
  publishing them to the queue for consumption by Broadway.
  """
  require Logger

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
  Calculates headers for the given payload so we can demonstrate routing in a
  headers exchange

  - pangram: true when prefix contains all 3 letters, e.g. ABC or CBA
  - double: true when prefix contains 2 of the same letter, e.g. AAB
  - triple: true when prefix contains 3 of the same letter, e.g. AAA
  """
  def headers(<<prefix::binary-size(3), _rest::binary>> = _payload) do
    freq_vals = prefix |> String.split("", trim: true) |> Enum.frequencies() |> Map.values()

    []
    |> Kernel.++(pangram_header(freq_vals))
    |> Kernel.++(double_header(freq_vals))
    |> Kernel.++(triple_header(freq_vals))
  end

  # Sets header of pangram: true if the message prefix contains one of each letter, e.g. ABC or BAC
  defp pangram_header(freq_vals) do
    if Enum.all?(freq_vals, &(&1 == 1)) do
      [{"pangram", :longstr, "true"}]
    else
      []
    end
  end

  # Sets header of double: true if the message prefix contains 2 of the same letter, e.g. AAB or CBC
  defp double_header(freq_vals) do
    if Enum.max(freq_vals) >= 2 do
      [{"double", :longstr, "true"}]
    else
      []
    end
  end

  # Sets header of triple: true if the message prefix contains 3 of the same letter, e.g. AAA
  defp triple_header(freq_vals) do
    if Enum.max(freq_vals) >= 3 do
      [{"triple", :longstr, "true"}]
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

  # @doc """
  # Publishes multiple messages to the given exchange using the given routing key.

  # ## Examples

  #     iex> Rarebit.Codes.publish_multiple("", "msgs", 60)
  #     iex> Rarebit.Codes.publish_multiple("headers_exchange", "", 100)
  # """
  # def publish_multiple(exchange, routing_key, n \\ 50) do
  #   with {:ok, connection} <- AMQP.Connection.open(Application.get_env(:amqp, :connections)),
  #        {:ok, channel} <- AMQP.Channel.open(connection) do
  #     Enum.each(1..n, fn _ ->
  #       payload = payload()
  #       headers = headers(payload)
  #       Logger.debug("Publishing message #{payload} headers #{inspect(headers)}")
  #       AMQP.Basic.publish(channel, exchange, routing_key, payload, headers: headers)
  #     end)
  #   end
  # end
end
