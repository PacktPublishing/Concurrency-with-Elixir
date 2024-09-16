# In this example, we use _awaited tasks_: `Task.yield_many/2` blocks execution
# while waiting for the tasks to complete. The result is a list of task output
# tuplies.  Each tuple includes a `%Task{}` struct and output from the task.
# If the task did not complete in the time alloted, a `nil` is returned, otherwise
# its output is wrapped in an `:ok` tuple, e.g.
#
# {%Task{
#    mfa: {:erlang, :apply, 2},
#    owner: #PID<0.94.0>,
#    pid: #PID<0.135.0>,
#    ref: #Reference<0.0.12035.4153126518.1312620545.58576>
#  }, {:ok, :done}}
#
# To run:
#
# mix run scripts/yield_many.exs
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
|> Task.yield_many()
|> IO.inspect()
