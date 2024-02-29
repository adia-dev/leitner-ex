# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Leitner.Repo.insert!(%Leitner.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Leitner.Accounts

password = "Respons11!"

Accounts.register_user(%{
  email: "adia.dev@gmail.com",
  username: "adia.dev",
  password: password
})

Enum.each(1..10, fn i ->
  case Accounts.register_user(%{
         email: "adia.dev.#{i}@gmail.com",
         username: "adia.dev.#{i}",
         password: password
       }) do
    {:ok, user} ->
      IO.inspect("User created: #{user.username}")

    {:error, error} ->
      IO.inspect("Failed to create user: #{error}")
  end
end)
