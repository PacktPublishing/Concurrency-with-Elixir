defmodule SupervisorExample do
  @doc "This function crashes half the time"
  def risky_work! do
    IO.puts("Starting risky work...")

    case Enum.random(1..2) do
      1 -> raise("Boom!")
      _ -> IO.puts("Work Ok")
    end
  end
end
