defmodule BreetheWeb.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(BreetheWeb.Endpoint, [])
      # Start your own worker by calling: BreetheWeb.Worker.start_link(arg1, arg2, arg3)
      # worker(BreetheWeb.Worker, [arg1, arg2, arg3]),
    ]

    :ok = :error_logger.add_report_handler(Sentry.Logger)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BreetheWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BreetheWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
