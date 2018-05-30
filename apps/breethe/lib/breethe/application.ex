defmodule Breethe.Application do
  @moduledoc """
  The Breethe Application Service.

  The breethe system business domain lives in this application.

  Exposes API to clients such as the `BreetheWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [
        supervisor(Breethe.Repo, []),
        supervisor(Task.Supervisor, [[name: Breethe.TaskSupervisor]])
      ],
      strategy: :one_for_one,
      name: Breethe.Supervisor
    )
  end
end
