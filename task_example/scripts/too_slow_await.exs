# In this example, we specify the timeout as the second option to: `Task.await_many/2`
# to see how it compares to `yield_many/2`.
# If these tasks experience a timeout, an error is raised, which will look
# something like the following:
#
# ** (exit) exited in: Task.await_many([%Task{mfa: {:erlang, :apply, 2}, owner: #PID<0.94.0>, pid: #PID<0.119.0>, ref: #Reference<0.0.12035.3354987544.2924544004.252946>}, %Task{mfa: {:erlang, :apply, 2}, owner: #PID<0.94.0>, pid: #PID<0.120.0>, ref: #Reference<0.0.12035.3354987544.2924544004.252947>}, %Task{mfa: {:erlang, :apply, 2}, owner: #PID<0.94.0>, pid: #PID<0.121.0>, ref: #Reference<0.0.12035.3354987544.2924544004.252948>}, %Task{mfa: {:erlang, :apply, 2}, owner: #PID<0.94.0>, pid: #PID<0.122.0>, ref: #Reference<0.0.12035.3354987544.2924544004.252949>}], 1000)
#     ** (EXIT) time out
#     (elixir 1.17.1) lib/task.ex:1011: Task.await_many/5
#     (elixir 1.17.1) lib/task.ex:995: Task.await_many/2
#     scripts/too_slow_await.exs:29: (file)
#
# To run:
#
# mix run scripts/too_slow_await.exs
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
|> Task.await_many(1000)
|> IO.inspect()
