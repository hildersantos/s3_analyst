defmodule S3Analyst.Mixfile do
  use Mix.Project

  def project do
    [app: :s3_analyst,
     version: "1.0.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :cache_tab, :hackney, :poison, :sweet_xml, :ex_aws]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_aws, "~> 1.1"}, # AWS Client
      {:poison, "~> 3.1"}, # JSON Encoder/Decoder
      {:sweet_xml, "~> 0.6.5"}, # XML Decoder to S3
      {:hackney, "~> 1.8", override: true}, # HTTP Client to make requests
      {:cache_tab, "~> 1.0"} # Caching mechanisms for requests
    ]
  end
end
