# This example shows how a task can be supervised and will restart on crashes.

# Normally we would start a supervisor inside our application's supervision tree,
# but for a simple stand-alone script, we can do the following to start up a
# supervisor
Task.Supervisor.start_link(name: SupervisorExample.TaskSupervisor)

Task.Supervisor.start_child(SupervisorExample.TaskSupervisor, fn ->
  SupervisorExample.risky_work!()
end, restart: :transient)

# If we are running this as a script, we need to prevent it from exiting to
# give our code time to complete.  You would normally not do this!
# Omit this line if you are pasting code into an iex session.
Process.sleep(100)
