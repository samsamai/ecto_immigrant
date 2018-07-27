defmodule Mix.EctoData do
  import Mix.Ecto
  # Conveniences for writing Mix.Tasks in EctoData.
  @moduledoc false

  @doc """
  Gets the data migrations path from a repository.
  """
  @spec data_migrations_path(Ecto.Repo.t()) :: String.t()
  def data_migrations_path(repo) do
    Path.join(source_repo_priv(repo), "data_migrations")
  end

  @doc """
  Ensures the given repository's data migrations path exists on the file system.
  """
  @spec ensure_data_migrations_path(Ecto.Repo.t()) :: Ecto.Repo.t()
  def ensure_data_migrations_path(repo) do
    with false <- Mix.Project.umbrella?(),
         path = Path.relative_to(data_migrations_path(repo), Mix.Project.app_path()),
         false <- File.dir?(path),
         do: raise_missing_data_migrations(path, repo)

    repo
  end

  defp raise_missing_data_migrations(path, repo) do
    Mix.raise("""
    Could not find ta damigrations directory #{inspect(path)}
    for repo #{inspect(repo)}.

    This may be because you are in a new project and the
    data migration directory has not been created yet. Creating an
    empty directory at the path above will fix this error.

    If you expected existing data migrations to be found, please
    make sure your repository has been properly configured
    and the configured path exists.
    """)
  end
end
