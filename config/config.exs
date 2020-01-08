# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config
#import Config

config :phoenix, :json_library, Jason

# General application configuration
config :stoneApi,
  ecto_repos: [StoneApi.Repo]

# Guardian
config :stoneApi, StoneApi.Guardian,
  issuer: "stoneApi",
  secret_key: "nqAch86bFGnfcmhY8qIuBUuBlv4JDsMoRH2RNL5/zkmglc4pOpb5i+xjtcGNvwu9"  

# Configures the endpoint
config :stoneApi, StoneApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Pkj+EbOWCVHhgajYIxDqdnB6IBU036EWuHSEH8uWB+S6AWZ8vA3c5FEVTk/FQcyp",
  render_errors: [view: StoneApiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: StoneApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
