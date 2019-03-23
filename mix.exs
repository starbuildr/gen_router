defmodule GenRouter.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_router,
      version: "0.1.3",
      elixir: "~> 1.6",
      description: "Elixir library to handle generic routing tasks in Plug.Router and Phoenix router style",
      docs: [extras: ["README.md"]],
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env == :prod,
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps()
    ]
  end

  def package do
    [
      name: :gen_router,
      files: ["lib", "mix.exs"],
      maintainers: ["Vyacheslav Voronchuk"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/starbuildr/gen_router"},
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/stub_modules"]
  defp elixirc_paths(_), do: ["lib"]
end
