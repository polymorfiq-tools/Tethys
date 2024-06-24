defmodule Tethys.MixProject do
  use Mix.Project

  def project do
    [
      app: :tethys,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Tethys.Application, []}
    ]
  end

  defp package do
    [
      description: "A networking library that guides and crafts the streams of information flowing through the modern world. Aiding the technological waters drawn from lakes, rivers, and rains as they move towards the world's oceans.",
      links: %{"GitHub" => "https://github.com/polymorfiq-tools/tethys"},
      licenses: ["AGPL-3.0-or-later"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
