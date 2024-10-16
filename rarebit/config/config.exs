# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :rarebit,
  ecto_repos: [Rarebit.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :rarebit, RarebitWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: RarebitWeb.ErrorHTML, json: RarebitWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Rarebit.PubSub,
  live_view: [signing_salt: "jDJCktFc"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :rarebit, Rarebit.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  rarebit: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  rarebit: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :amqp,
  connections: [
    # credentials in a URL
    # myconn: [
    #   url: "amqp://guest:guest@localhost:15672"
    # ]
    # OR more verbose
    default: [
      # url: "amqp://guest:guest@localhost:15672"
      host: "localhost",
      port: 5672,
      username: "guest",
      password: "guest"
    ]
    # OR fall back to the default stuff
    # default: []
  ],
  # Set up some channels
  channels: [
    codes: [connection: :default]
  ]

config :rarebit,
  producer_module:
    {BroadwayRabbitMQ.Producer,
     [
       #  queue: "bikes_queue",
       queue: "bikes",
       qos: [
         prefetch_count: 50
       ],
       on_failure: :reject_and_requeue
     ]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
