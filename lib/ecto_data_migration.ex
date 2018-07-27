defmodule EctoDataMigration do
  @moduledoc """
  Documentation for EctoDataMigration.
  """

  @doc """
  Hello world.

  ## Examples

      iex> EctoDataMigration.hello
      :world

  """
  def hello do
    :world
  end
end

defmodule EctoData.MigrationError do
  defexception [:message]
end
