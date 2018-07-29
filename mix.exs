defmodule EctoImmigrant.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_immigrant,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
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
      {:ecto, "~> 2.1"},
      {:ex_doc, "~> 0.17", only: :docs},
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 0.6", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Sam Samai"],
      licenses: ["Apache 2"],
      links: %{"GitHub" => "https://github.com/samsamai/ecto_immigrant"}
    ]
  end
end
