defmodule TaskExample do
  @doc """

  Here's an example of sequential code: making HTTP requests
  to multiple URLs:

      IO.puts("Starting at #{DateTime.utc_now()}")
      urls = [
        "https://example.com/page1",
        "https://example.com/page2",
        "https://example.com/page3",
        "https://example.com/page4"
      ]
      Enum.each(urls, &TaskExample.request/1)
      IO.puts("Finishing at #{DateTime.utc_now()}")

      iex> (
      ...> IO.puts("Starting at #{DateTime.utc_now()}")
      ...>       urls = [
      ...>         "https://example.com/page1",
      ...>         "https://example.com/page2",
      ...>         "https://example.com/page3",
      ...>         "https://example.com/page4"
      ...>       ]
      ...>       Enum.each(urls, &TaskExample.request/1)
      ...>       IO.puts("Finishing at #{DateTime.utc_now()}")
      ...> )
      Starting at 2024-06-30 20:22:00.123390Z
      completing work...
      completing work...
      completing work...
      completing work...
      Finishing at 2024-06-30 20:22:00.127991Z

  If each request takes 3 seconds to, this code takes 12 seconds to complete.

  We can change sequential code to concurrent code by leveraging the `Task` module.

      IO.puts("Starting at #{DateTime.utc_now()}")
      urls = [
        "https://example.com/page1",
        "https://example.com/page2",
        "https://example.com/page3",
        "https://example.com/page4"
      ]
      Enum.each(urls, fn url -> Task.start(fn -> TaskExample.request(url) end) end)
      IO.puts("Finishing at #{DateTime.utc_now()}")

  The output of this is quite different.  The first thing to notice is that it
  completes almost instantly (within a few milliseconds). Then after 3 seconds, we
  see 4 instances of our workload completed.

      Starting at 2024-06-30 20:28:06.760237Z
      Finishing at 2024-06-30 20:28:06.760848Z
      :ok
      completing work...
      completing work...
      completing work...
      completing work...


  In the above example that uses `Task.start/1`, the function called is intended
  to be a side-effect -- it does not return a value (or at least, we cannot access
  the return value). Another hint that the return values are ignored is the use
  of `Enum.each/2` instead of `Enum.map/2`


  If we need the returned values, then we cannot rely on `Task.start/1` and we must
  instead use `Task.async/1` and either an `await` or a `yield` function.

        urls
        |> Enum.map(fn url -> Task.async(fn -> TaskExample.request(url) end) end)
        |> Enum.map(fn task -> Task.await(task, 1000) end)

        urls
        |> Enum.map(fn url -> Task.async(fn -> TaskExample.request(url) end) end)
        |> Task.await_many(1000)

        IO.puts("Starting at #{DateTime.utc_now()}")
        urls
        |> Enum.map(fn url -> Task.async(fn -> TaskExample.request(url) end) end)
        |> Enum.map(fn task -> Task.yield(task, 1000) end)
        IO.puts("Completing at #{DateTime.utc_now()}")

        urls
        |> Enum.map(fn url -> Task.async(fn -> TaskExample.request(url) end) end)
        |> Task.yield_many(1000)

        urls
        |> Enum.map(fn url -> Task.async(fn -> TaskExample.request(url) end) end)
        |> Task.yield_many(2000)

  In the
  following example, we use `Enum.map/2` to convert our URLs into tasks, and
  then we await for them to complete using `Task.await_many/1`.

      IO.puts("Starting at #{DateTime.utc_now()}")
      urls = [
        "https://example.com/page1",
        "https://example.com/page2",
        "https://example.com/page3",
        "https://example.com/page4"
      ]
      tasks = Enum.map(urls, fn url -> Task.async(fn -> TaskExample.request(url) end) end)
      Task.await_many(tasks)
      IO.puts("Finishing at #{DateTime.utc_now()}")


  Here is a functionally equivalent example that maps each task to `Task.await/1` instead
  of using `Task.await_many/1`:

      IO.puts("Starting at #{DateTime.utc_now()}")
      urls = [
        "https://example.com/page1",
        "https://example.com/page2",
        "https://example.com/page3",
        "https://example.com/page4"
      ]
      stream = Task.async_stream(urls, fn url -> TaskExample.request(url) end)
      Enum.to_list(stream)
      IO.puts("Finishing at #{DateTime.utc_now()}")


      iex> Task.start(fn -> TaskExample.request() end)
      {:ok, #PID<0.190.0>}

      # three seconds later, you will see
      completing work...
  """
  def request(_url) do
    # Simulate hard work
    Process.sleep(3_000)
    IO.puts("completing request")
    :done
  end

  def risky_work do
    IO.puts("Starting risky work...")
    case Enum.random(1..2) do
      1 ->
        raise("Boom!")

      _ ->
        IO.puts("Work Ok")
    end
  end
end
