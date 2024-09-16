# In this example, we look at the `max_concurrency` option provided to
# Task.async_stream/3.  If we allow only 2 concurrent processes, then the total
# execution time should be half of what sequential execution would take.
#
# To run:
#
# mix run scripts/async_stream.exs
urls = [
        "https://example.com/page1",
        "https://example.com/page2",
        "https://example.com/page3",
        "https://example.com/page4"
      ]

IO.puts("Starting at: #{DateTime.utc_now()}")
urls
|> Task.async_stream(fn url -> TaskExample.request(url) end, max_concurrency: 2)
|> Enum.to_list()
|> IO.inspect()
IO.puts("Finishing at: #{DateTime.utc_now()}")
