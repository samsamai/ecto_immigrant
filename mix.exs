defmodule EctoImmigrant.MixProject do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :ecto_immigrant,
      description: "Data migrations for your ecto-backed elixir application",
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.5"},
      {:ecto_sql, "~> 3.5"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Sam Samai"],
      licenses: ["Apache 2"],
      links: %{"GitHub" => "https://github.com/samsamai/ecto_immigrant"}
    ]
  end

  defp description do
    """
    Data migrations for your ecto-backed elixir application.
    """
  end
end
