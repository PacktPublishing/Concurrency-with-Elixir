Task.Supervisor.start_link(name: SupervisorExample.TaskSupervisor)

# This works, but it doesn't restart????
task = Task.Supervisor.async_nolink(SupervisorExample.TaskSupervisor, fn ->
  SupervisorExample.risky_work()
end)
# Same here...
task = Task.Supervisor.async(SupervisorExample.TaskSupervisor, fn ->
  SupervisorExample.risky_work!()
end)
# Task.await(task)
Task.yield(task)
IO.puts("Done.")
