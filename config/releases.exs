import Config

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
app_port = System.fetch_env!("APP_PORT")
app_hostname = System.fetch_env!("APP_HOSTNAME")
db_user = System.fetch_env!("DB_USER")
db_password = System.fetch_env!("DB_PASSWORD")
db_host = System.fetch_env!("DB_HOST")

config :stoneApi, StoneApiWeb.Endpoint,
       http: [:inet6, port: String.to_integer(app_port)],
       secret_key_base: secret_key_base

config :stoneApi,
       app_port: app_port

config :stoneApi,
       app_hostname: app_hostname

# Configure your database
config :stoneApi, StoneApi.Repo,
       adapter: Ecto.Adapters.Postgres,
       username: db_user,
       password: db_password,
       database: "stoneapi_dev",
       hostname: db_host,
       pool_size: 10
