defmodule SupervisorExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # {Task.Supervisor, name: SupervisorExample.TaskSupervisor}
      {Task.Supervisor, name: SupervisorExample.TaskSupervisor}
      # Or, More verbosely:
      # %{
      #   id: SupervisorExample.TaskSupervisor,
      #   start: {Task.Supervisor, :start_link, [[name: SupervisorExample.TaskSupervisor]]},
      #   restart: :permanent,
      #   type: :supervisor
      # }
    ]

    opts = [strategy: :one_for_one, name: SupervisorExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
