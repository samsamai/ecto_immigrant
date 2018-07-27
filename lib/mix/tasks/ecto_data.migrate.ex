defmodule Mix.Tasks.EctoData.Migrate do
  use Mix.Task
  import Mix.Ecto
  import Mix.EctoData

  alias Mix.Project

  @shortdoc "Runs the repository data migrations"

  @moduledoc """
  Runs the pending data migrations for the given repository.

  Data migrations are expected at "priv/YOUR_REPO/data_migrations" directory
  of the current application, where "YOUR_REPO" is the last segment
  in your repository name. For example, the repository `MyApp.Repo`
  will use "priv/repo/data_migrations". The repository `Whatever.MyRepo`
  will use "priv/my_repo/data_migrations".

  This task runs all pending data migrations by default.

  If a repository has not yet been started, one will be started outside
  your application supervision tree and shutdown afterwards.

  ## Examples

      mix ecto.data.migrate

  ## Command line options

  """

  @doc false
  def run(args, migrator \\ &EctoData.Migrator.run/4) do
    repos = parse_repo(args)
    opts = [all: true]

    Enum.each(repos, fn repo ->
      ensure_repo(repo, args)
      ensure_data_migrations_path(repo)
      {:ok, pid, apps} = ensure_started(repo, opts)

      pool = repo.config[:pool]

      migrated =
        if function_exported?(pool, :unboxed_run, 2) do
          pool.unboxed_run(repo, fn -> migrator.(repo, data_migrations_path(repo), :up, opts) end)
        else
          migrator.(repo, data_migrations_path(repo), :up, opts)
        end

      pid && repo.stop(pid)
      restart_apps_if_migrated(apps, migrated)
    end)
  end
end
