defmodule EctoImmigrant.MigratorTest do
  use ExUnit.Case

  import Support.FileHelpers
  import EctoImmigrant.Migrator
  import ExUnit.CaptureLog

  alias EctoImmigrant.TestRepo
  alias EctoImmigrant.DataMigration

  defmodule Migration do
    use EctoImmigrant.Migration

    def up do
    end
  end

  defmodule UpMigration do
    use EctoImmigrant.Migration

    def up do
      # Do some heavy SQL here
    end
  end

  defmodule NoTransactionMigration do
    use EctoImmigrant.Migration
    @disable_ddl_transaction true

    def up do
      # Do some heavy SQL here
    end
  end

  defmodule InvalidMigration do
    use EctoImmigrant.Migration
  end

  defmodule EmptyModule do
  end

  defmodule TestDataRepo do
    use Ecto.Repo, otp_app: :ecto_immigrant, adapter: EctoImmigrant.TestAdapter
  end

  Application.put_env(:ecto_immigrant, TestDataRepo, data_migration_source: "my_data_migrations")

  setup do
    Process.put(:migrated_versions, [1, 2, 3])
    :ok
  end

  test "custom data migrations table is right" do
    assert DataMigration.get_source(TestRepo) == "data_migrations"
    assert DataMigration.get_source(TestDataRepo) == "my_data_migrations"
  end

  test "logs migrations" do
    output =
      capture_log(fn ->
        :ok = up(TestRepo, 0, UpMigration)
      end)

    assert output =~ "== Running EctoImmigrant.MigratorTest.UpMigration.up/0 forward"
    assert output =~ ~r"== Migrated in \d.\ds"
  end

  test "up invokes the repository adapter with up commands" do
    assert up(TestRepo, 0, Migration, log: false) == :ok
    assert up(TestRepo, 1, Migration, log: false) == :already_up
    assert up(TestRepo, 10, UpMigration, log: false) == :ok
  end

  test "up raises error when missing up/0" do
    assert_raise EctoImmigrant.MigrationError, fn ->
      EctoImmigrant.Migrator.up(TestRepo, 0, InvalidMigration, log: false)
    end
  end

  test "expects files starting with an integer" do
    in_tmp(fn path ->
      create_migration("a_sample.exs")
      assert run(TestRepo, path, :up, all: true, log: false) == []
    end)
  end

  test "fails if there is no migration in file" do
    in_tmp(fn path ->
      File.write!("13_sample.exs", ":ok")

      assert_raise EctoImmigrant.MigrationError,
                   "file 13_sample.exs is not an EctoImmigrant.Migration",
                   fn ->
                     run(TestRepo, path, :up, all: true, log: false)
                   end
    end)
  end

  test "fails if there are duplicated versions" do
    in_tmp(fn path ->
      create_migration("13_hello.exs")
      create_migration("13_other.exs")

      assert_raise EctoImmigrant.MigrationError,
                   "data migrations can't be executed, data migration version 13 is duplicated",
                   fn ->
                     run(TestRepo, path, :up, all: true, log: false)
                   end
    end)
  end

  test "fails if there are duplicated name" do
    in_tmp(fn path ->
      create_migration("13_hello.exs")
      create_migration("14_hello.exs")

      assert_raise EctoImmigrant.MigrationError,
                   "data migrations can't be executed, data migration name hello is duplicated",
                   fn ->
                     run(TestRepo, path, :up, all: true, log: false)
                   end
    end)
  end

  test "upwards migrations skips migrations that are already up" do
    in_tmp(fn path ->
      create_migration("1_sample.exs")
      assert run(TestRepo, path, :up, all: true, log: false) == []
    end)
  end

  # test "migrations will give the up and down migration status" do
  #   in_tmp(fn path ->
  #     create_migration("1_up_migration_1.exs")
  #     create_migration("2_up_migration_2.exs")
  #     create_migration("3_up_migration_3.exs")
  #     create_migration("4_down_migration_1.exs")
  #     create_migration("5_down_migration_2.exs")

  #     expected_result = [
  #       {:up, 1, "up_migration_1"},
  #       {:up, 2, "up_migration_2"},
  #       {:up, 3, "up_migration_3"},
  #       {:down, 4, "down_migration_1"},
  #       {:down, 5, "down_migration_2"}
  #     ]

  #     assert migrations(TestRepo, path) == expected_result
  #   end)
  # end

  test "migrations run inside a transaction if the adapter supports ddl transactions" do
    capture_log(fn ->
      Process.put(:supports_ddl_transaction?, true)
      up(TestRepo, 0, UpMigration)
      assert_receive {:transaction, _}
    end)
  end

  test "migrations can be forced to run outside a transaction" do
    capture_log(fn ->
      Process.put(:supports_ddl_transaction?, true)
      up(TestRepo, 0, NoTransactionMigration)
      refute_received {:transaction, _}
    end)
  end

  test "migrations does not run inside a transaction if the adapter does not support ddl transactions" do
    capture_log(fn ->
      Process.put(:supports_ddl_transaction?, false)
      up(TestRepo, 0, UpMigration)
      refute_received {:transaction, _}
    end)
  end

  defp create_migration(name) do
    module = name |> Path.basename() |> Path.rootname()

    File.write!(name, """
    defmodule EctoImmigrant.MigrationTest.S#{module} do
      use EctoImmigrant.Migration

      def up do
      end
    end
    """)
  end

  describe "alternate migration source format" do
    test "fails if there is no migration in file" do
      assert_raise EctoImmigrant.MigrationError,
                   "module EctoImmigrant.MigratorTest.EmptyModule is not an EctoImmigrant.Migration",
                   fn ->
                     run(TestRepo, [{13, EmptyModule}], :up, all: true, log: false)
                   end
    end

    test "fails if the module does not define migrations" do
      assert_raise EctoImmigrant.MigrationError,
                   "EctoImmigrant.MigratorTest.InvalidMigration does not implement a `up/0` function",
                   fn ->
                     run(TestRepo, [{13, InvalidMigration}], :up, all: true, log: false)
                   end
    end

    test "fails if there are duplicated versions" do
      assert_raise EctoImmigrant.MigrationError,
                   "data migrations can't be executed, data migration version 13 is duplicated",
                   fn ->
                     run(
                       TestRepo,
                       [{13, UpMigration}, {13, Migration}],
                       :up,
                       all: true,
                       log: false
                     )
                   end
    end

    test "fails if there are duplicated name" do
      assert_raise EctoImmigrant.MigrationError,
                   "data migrations can't be executed, data migration name Elixir.EctoImmigrant.MigratorTest.UpMigration is duplicated",
                   fn ->
                     run(
                       TestRepo,
                       [{13, UpMigration}, {14, UpMigration}],
                       :up,
                       all: true,
                       log: false
                     )
                   end
    end

    test "upwards migrations skips migrations that are already up" do
      assert run(TestRepo, [{1, UpMigration}], :up, all: true, log: false) == []
    end
  end
end
