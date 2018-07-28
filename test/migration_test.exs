defmodule EctoImmigrant.MigrationTest do
  use ExUnit.Case

  use EctoImmigrant.Migration

  test "defines __migration__ function" do
    assert function_exported?(__MODULE__, :__data_migration__, 0)
  end
end
