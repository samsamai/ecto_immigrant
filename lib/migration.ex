defmodule EctoImmigrant.Migration do
  @moduledoc """
  Data migrations are used to modify the data in your database over time.

  This module provides many helpers for migrating the database,
  allowing developers to use Elixir to alter their storage in
  a way that is database independent.

  Here is an example:

      defmodule ExampleApp.Repo.DataMigrations.AddJohn do
        use EctoImmigrant.Migration
        alias ExampleApp.Repo
        alias ExampleApp.Person

        def up do
          Repo.insert(%Person{id: 123, first_name: "John", last_name: "Doe", age: 78})
        end

        def down do
          Repo.delete(%Person{id: 123, first_name: "John", last_name: "Doe", age: 78})
        end
      end

  Note data migrations have an `up/0` and `down/0`, which is used to update your data
  and reverts the updated data, respectively.

  EctoImmigrant provides some mix tasks to help developers work with migrations:

    * `mix ecto_immigrant.gen.migration` # Generates a new data migration for the repo
    * `mix ecto_immigrant.migrate`       # Runs the repository data migrations
    * `mix ecto_immigrant.rollback`      # Reverts applied data migrations from the repository
    * `mix ecto_immigrant.migrations`    # Displays the repository data migration status

  Run the `mix help COMMAND` for more information.

  ## Transactions

  By default, Ecto_Immigrant runs all migrations inside a transaction. That's not always
  ideal: for example, PostgreSQL allows to create/drop indexes concurrently but
  only outside of any transaction (see the [PostgreSQL
  docs](http://www.postgresql.org/docs/9.2/static/sql-createindex.html#SQL-CREATEINDEX-CONCURRENTLY)).

  Data migrations can be forced to run outside a transaction by setting the
  `@disable_ddl_transaction` module attribute to `true`:

      defmodule ExampleApp.Repo.DataMigrations.AddJohn do
        use EctoImmigrant.Migration
        @disable_ddl_transaction true

        alias ExampleApp.Repo
        alias ExampleApp.Person

        def up do
          Repo.insert(%Person{id: 123, first_name: "John", last_name: "Doe", age: 78})
        end

        def down do
          Repo.delete(%Person{id: 123, first_name: "John", last_name: "Doe", age: 78})
        end
      end

  Since running migrations outside a transaction can be dangerous, consider
  performing very few operations in such migrations.

  """

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      import EctoImmigrant.Migration
      @disable_ddl_transaction false
      @before_compile EctoImmigrant.Migration
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def __data_migration__,
        do: [disable_ddl_transaction: @disable_ddl_transaction]
    end
  end
end
