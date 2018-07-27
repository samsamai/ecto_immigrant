defmodule EctoData.Migration do
  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      import EctoData.Migration
      @disable_ddl_transaction false
      @before_compile EctoData.Migration
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
