defmodule Mix.Tasks.EctoImmigrant.Rollback do
  use Mix.Task
  import Mix.Ecto
  import Mix.EctoImmigrant

  @shortdoc "Roll backs the repository data migrations"

  @moduledoc """
  Reverts applied data migrations for the given repository.

  Data migrations are expected at "priv/YOUR_REPO/data_migrations" directory
  of the current application, where "YOUR_REPO" is the last segment
  in your repository name. For example, the repository `MyApp.Repo`
  will use "priv/repo/data_migrations". The repository `Whatever.MyRepo`
  will use "priv/my_repo/data_migrations".

  This task rolls back the last applied data migrations by default.

  If a repository has not yet been started, one will be started outside
  your application supervision tree and shutdown afterwards.

  ## Examples

      mix ecto_immigrant.rollback
      mix ecto_immigrant.rollback -r Custom.Repo

      mix ecto_immigrant.rollback -n 3
      mix ecto_immigrant.rollback --step 3

      mix ecto_immigrant.rollback --to 20080906120000

  ## Command line options

    * `-r`, `--repo` - the repo to rollback

    * `--all` - revert all applied migrations

    * `--step`, `-n` - revert n number of applied migrations

    * `--to` - revert all migrations down to and including version

    * `--quiet` - do not log migration commands

    * `--prefix` - the prefix to run migrations on

    * `--log-sql` - log the raw sql migrations are running
  """

  @aliases [
    r: :repo,
    n: :step
  ]

  @switches [
    all: :boolean,
    step: :integer,
    to: :integer,
    quiet: :boolean,
    prefix: :string,
    log_sql: :boolean,
    repo: [:keep, :string]
  ]

  @doc false
  def run(args, migrator \\ &EctoImmigrant.Migrator.run/4) do
    repos = parse_repo(args)
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    opts =
      if opts[:to] || opts[:step] || opts[:all],
        do: opts,
        else: Keyword.put(opts, :step, 1)

    for repo <- repos do
      ensure_repo(repo, args)
      ensure_data_migrations_path(repo)
      Mix.Task.run("app.start")
      repo.start_link(opts)

      pool = repo.config[:pool]

      if function_exported?(pool, :unboxed_run, 2) do
        pool.unboxed_run(repo, fn -> migrator.(repo, data_migrations_path(repo), :down, opts) end)
      else
        migrator.(repo, data_migrations_path(repo), :down, opts)
      end
    end
  end
end
