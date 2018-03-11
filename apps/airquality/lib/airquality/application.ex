defmodule Airquality.Application do
  @moduledoc """
  The Airquality Application Service.

  The airquality system business domain lives in this application.

  Exposes API to clients such as the `AirqualityWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [
        supervisor(Airquality.Repo, [])
      ],
      strategy: :one_for_one,
      name: Airquality.Supervisor
    )
  end
end
