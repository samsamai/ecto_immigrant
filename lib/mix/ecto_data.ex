defmodule Mix.EctoData do
  import Mix.Ecto
  # Conveniences for writing Mix.Tasks in Ecto.
  @moduledoc false

  @doc """
  Gets the migrations path from a repository.
  """
  @spec data_migrations_path(Ecto.Repo.t()) :: String.t()
  def data_migrations_path(repo) do
    Path.join(source_repo_priv(repo), "data_migrations")
  end
end
