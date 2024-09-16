# Because the `SupervisorExample.risky_work/0` function crashes half the time,
# our task will exit half the time.
#
# To run, paste the code into an iex session or run the following command from
# the terminal:
# mix run scripts/task.exs
task = Task.async(fn -> SupervisorExample.risky_work() end)
Task.await(task)
