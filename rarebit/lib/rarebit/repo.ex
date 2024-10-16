defmodule Rarebit.Repo do
  use Ecto.Repo,
    otp_app: :rarebit,
    adapter: Ecto.Adapters.Postgres
end
