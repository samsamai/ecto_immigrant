defmodule Mix.Tasks.EctoImmigrant.Migrations do
  use Mix.Task
  import Mix.Ecto
  import Mix.EctoImmigrant

  @shortdoc "Displays the repository data migration status"

  @moduledoc """
  Displays the up / down data migration status for the given repository.

  The repository must be set under `:ecto_repos` in the
  current app configuration or given via the `-r` option.

  By default, data migrations are expected at "priv/YOUR_REPO/data_migrations"
  directory of the current application but it can be configured
  by specifying the `:priv` key under the repository configuration.

  If the repository has not been started yet, one will be
  started outside our application supervision tree and shutdown
  afterwards.

  ## Examples

      mix ecto_immigrant.migrations
      mix ecto_immigrant.migrations -r Custom.Repo

  ## Command line options

    * `-r`, `--repo` - the repo to obtain the status for

  """

  @doc false
  def run(args, migrations \\ &EctoImmigrant.Migrator.migrations/2, puts \\ &IO.puts/1) do
    repos = parse_repo(args)
    opts = [all: true]

    result =
      Enum.map(repos, fn repo ->
        ensure_repo(repo, args)
        ensure_data_migrations_path(repo)
        Mix.Task.run("app.start")
        repo.start_link(opts)

        repo_status = migrations.(repo, data_migrations_path(repo))

        """

        Repo: #{inspect(repo)}

          Status    Data migration ID    Data migration Name
        -------------------------------------------------------
        """ <> data_migrations_rows(repo_status)
      end)

    puts.(Enum.join(result, "\n"))
  end

  defp data_migrations_rows(repo_status) do
    Enum.map_join(repo_status, "\n", fn {status, number, description} ->
      status =
        case status do
          :up -> "up  "
          :down -> "down"
        end

      "  #{status}      #{number}       #{description}"
    end) <> "\n"
  end
end
