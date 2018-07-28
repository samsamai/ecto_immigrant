defmodule Mix.Tasks.EctoImmigrant.MigrationsTest do
  use ExUnit.Case

  import Mix.Tasks.EctoImmigrant.Migrations, only: [run: 3]
  import Support.FileHelpers

  migrations_path = Path.join([tmp_path(), inspect(EctoImmigrant.Migrations), "data_migrations"])

  setup do
    File.mkdir_p!(unquote(migrations_path))
    :ok
  end

  defmodule Repo do
    def start_link(_) do
      Process.put(:started, true)

      Task.start_link(fn ->
        Process.flag(:trap_exit, true)

        receive do
          {:EXIT, _, :normal} -> :ok
        end
      end)
    end

    def stop(_pid) do
      :ok
    end

    def __adapter__ do
      EctoImmigrant.TestAdapter
    end

    def config do
      [priv: "tmp/#{inspect(EctoImmigrant.Migrations)}", otp_app: :ecto_immigrant]
    end
  end

  test "migrations displays the up status for the default repo" do
    Application.put_env(:ecto_immigrant, :ecto_repos, [Repo])

    migrations = fn _, _ ->
      [
        {:up, 20_160_000_000_001, "up_migration_1"},
        {:up, 20_160_000_000_002, "up_migration_2"},
        {:up, 20_160_000_000_003, "up_migration_3"}
      ]
    end

    expected_output = """

    Repo: Mix.Tasks.EctoImmigrant.MigrationsTest.Repo

      Status    Data migration ID    Data migration Name
    -------------------------------------------------------
      up        20160000000001       up_migration_1
      up        20160000000002       up_migration_2
      up        20160000000003       up_migration_3
    """

    run([], migrations, fn i -> assert(i == expected_output) end)
  end

  test "migrations displays the up status for any given repo" do
    migrations = fn _, _ ->
      [
        {:up, 20_160_000_000_001, "up_migration_1"}
      ]
    end

    expected_output = """

    Repo: Mix.Tasks.EctoImmigrant.MigrationsTest.Repo

      Status    Data migration ID    Data migration Name
    -------------------------------------------------------
      up        20160000000001       up_migration_1
    """

    run(["-r", to_string(Repo)], migrations, fn i -> assert(i == expected_output) end)
  end
end
