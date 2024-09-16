defmodule SupervisorExample.Server do
  use GenServer

  def start_link(initial_val) do
    GenServer.start_link(__MODULE__, initial_val, name: __MODULE__)
  end

  def init(_initial_val)
    # do {:ok, initial_val}
    do {:ok, %{ref: nil}}
  end

  def something do
    GenServer.call(__MODULE__, :something)
  end

  def something(pid) do
    GenServer.call(pid, :something)
  end

  def start_task do
    GenServer.call(__MODULE__, :start_task)
  end

  # In this case the task is already running, so we just return :ok.
  def handle_call(:start_task, _from, %{ref: ref} = state) when is_reference(ref) do
    {:reply, :ok, state}
  end

  # The task is not running yet, so let's start it.
  def handle_call(:start_task, _from, %{ref: nil} = state) do
    task =
      Task.Supervisor.async_nolink(SupervisorExample.TaskSupervisor, fn ->
        SupervisorExample.risky_work!()
      end)

    # We return :ok and the server will continue running
    {:reply, :ok, %{state | ref: task.ref}}
  end

  # The task completed successfully
  def handle_info({ref, answer}, %{ref: ref} = state) do
    dbg(answer)
    # We don't care about the DOWN message now, so let's demonitor and flush it
    result = Process.demonitor(ref, [:flush])
    dbg(result)
    # Do something with the result and then return
    {:noreply, %{state | ref: nil}}
  end

  # The task failed
  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{ref: ref} = state) do
    # Log and possibly restart the task...
    IO.puts("GOING DOWN!!!")
    {:noreply, %{state | ref: nil}}
  end
end
