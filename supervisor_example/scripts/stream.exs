# Task.Supervisor.async_stream will exit when it hits an error
# If we need to accumulate the results, we can convert the stream to a list
# via Enum.to_list/1; otherwise use Stream.run/1 to execute the stream
# 1..10
# |> Task.async_stream(
#   fn _ ->
#     SupervisorExample.risky_work!()
#   end,
#   max_concurrency: 4
# )
# |> Enum.to_list()

# When a task in here raises an error, then iex itself will crash!
Task.Supervisor.async_stream(
  SupervisorExample.TaskSupervisor,
  1..10,
  fn _item ->
    SupervisorExample.risky_work!()
  end,
  max_concurrency: 4
)
|> Enum.to_list()

# |> IO.inspect()

Task.Supervisor.async_stream_nolink(
  SupervisorExample.TaskSupervisor,
  1..10,
  fn _item ->
    SupervisorExample.risky_work!()
  end,
  max_concurrency: 4
)
|> Enum.to_list()

# |> IO.inspect()

# Process.sleep(1000)
# IO.puts("DONEEE")
