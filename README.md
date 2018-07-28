# Ecto Immigrant

This package helps you to do data migrations in your ecto-backed elixir application.

It keeps track of which data migrations are run and stores this in the database, same as how ecto does schema migrations. In fact all the code for this has been borrowed from ecto and changed slightly to work for data migrations, all credit goes to the ecto team.

Three mix tasks are created by this package:

```
mix ecto_immigrant.gen.migration # Generates a new data migration for the repo
mix ecto_immigrant.migrate       # Runs the repository data migrations
mix ecto_immigrant.migrations    # Displays the repository data migration status
```

Data migrations are created in `priv/repo/data_migrations` dir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_immigrant` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_immigrant, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ecto_immigrant](https://hexdocs.pm/ecto_immigrant).

