# In this example, we specify the timeout as the second option to: `Task.yield_many/2`
# This means that the the tasks won't have enough time to complete.  As a result,
# the return value includes `nil`s, e.g.
#
# {%Task{
#    mfa: {:erlang, :apply, 2},
#    owner: #PID<0.94.0>,
#    pid: #PID<0.135.0>,
#    ref: #Reference<0.0.12035.4153126518.1312620545.58576>
#  }, nil}
#
# To run:
#
# mix run scripts/too_slow_yield.exs
urls = [
        "https://example.com/page1",
        "https://example.com/page2",
        "https://example.com/page3",
        "https://example.com/page4"
      ]

urls
|> Enum.map(fn url ->
  Task.async(fn ->
    TaskExample.request(url)
  end)
end)
|> Task.yield_many(1000)
|> IO.inspect()
