defmodule EctoImmigrant.DataMigration do
  # Define a schema that works with the a table, which is data_migrations by default
  @moduledoc false
  use Ecto.Schema

  import Ecto.Query, only: [from: 2]

  @primary_key false
  schema "data_migrations" do
    field(:version, :integer)
    timestamps(updated_at: false)
  end

  # the schema migration flag is a signal to the repo that we are in a migration operation
  @opts [timeout: :infinity, log: false, schema_migration: true]

  def ensure_data_migrations_table!(repo, prefix) do
    adapter = repo.__adapter__()
    create_data_migrations_table(adapter, repo, prefix)
  end

  def migrated_versions(repo, prefix) do
    from(p in {get_source(repo), __MODULE__}, select: p.version)
    |> Map.put(:prefix, prefix)
    |> repo.all(@opts)
  end

  def up(repo, version, prefix) do
    %__MODULE__{version: version}
    |> Ecto.put_meta(prefix: prefix, source: get_source(repo))
    |> repo.insert!(@opts)
  end

  def down(repo, version, prefix) do
    from(p in {get_source(repo), __MODULE__}, where: p.version == ^version)
    |> Map.put(:prefix, prefix)
    |> repo.delete_all(@opts)
  end

  def get_source(repo) do
    Keyword.get(repo.config(), :data_migration_source, "data_migrations")
  end

  defp create_data_migrations_table(adapter, repo, prefix) do
    table_name = repo |> get_source |> String.to_atom()
    table = %Ecto.Migration.Table{name: table_name, prefix: prefix}

    # DDL queries do not log, so we do not need to pass log: false here.
    adapter.execute_ddl(
      repo,
      {:create_if_not_exists, table,
       [{:add, :version, :bigint, primary_key: true}, {:add, :inserted_at, :naive_datetime, []}]},
      @opts
    )
  end
end
