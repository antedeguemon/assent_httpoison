defmodule AssentHTTPoison.MixProject do
  use Mix.Project

  def project do
    [
      app: :assent_httpoison,
      version: "0.1.1",
      description: "Assent adapter for making requests using HTTPoison",
      package: package(),
      docs: docs(),
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:assent, ">= 0.1.11"},
      {:bandit, "~> 1.1", only: :test},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:httpoison, "~> 1.8.0"},
      {:test_server, "~> 0.1.13", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/antedeguemon/assent_httpoison"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
