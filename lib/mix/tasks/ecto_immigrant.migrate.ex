defmodule Mix.Tasks.EctoImmigrant.Migrate do
  use Mix.Task
  import Mix.Ecto
  import Mix.EctoImmigrant

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

      mix ecto_immigrant.migrate

  """

  @doc false
  def run(args, migrator \\ &EctoImmigrant.Migrator.run/4) do
    repos = parse_repo(args)
    opts = [all: true]

    Enum.each(repos, fn repo ->
      ensure_repo(repo, args)
      ensure_data_migrations_path(repo)
      Mix.Task.run("app.start")
      repo.start_link(opts)

      pool = repo.config()[:pool]

      if function_exported?(pool, :unboxed_run, 2) do
        pool.unboxed_run(repo, fn -> migrator.(repo, data_migrations_path(repo), :up, opts) end)
      else
        migrator.(repo, data_migrations_path(repo), :up, opts)
      end
    end)
  end
end
