defmodule Hoeg.MixProject do
  use Mix.Project

  def project do
    [
      app: :hoeg,
      version: "0.2.0",
      elixir: "~> 1.10",
      elixirc_options: [warnings_as_errors: true],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nimble_parsec, "~> 0.6"},
      {:excoveralls, "~> 0.8", only: :test}
    ]
  end
end
