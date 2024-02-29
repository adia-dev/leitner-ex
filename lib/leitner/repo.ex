defmodule Leitner.Repo do
  use Ecto.Repo,
    otp_app: :leitner,
    adapter: Ecto.Adapters.Postgres
end
