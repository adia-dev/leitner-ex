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
alias Leitner.Cards

password = "Respons11!"

Accounts.register_user(%{
  email: "adia.dev@gmail.com",
  username: "adia.dev",
  password: password
})

Enum.each(1..10, fn i ->
  Accounts.register_user(%{
    email: "adia.dev.#{i}@gmail.com",
    username: "adia.dev.#{i}",
    password: password
  })
end)

categories = [:first, :second, :third, :fourth, :fifth, :sixth, :seventh, :done]
all_users = Accounts.list_users()

Enum.each(1..10, fn i ->
  category = Enum.random(categories)
  random_tag = Enum.random(["maths", "science", "big brain", "thinking", "algebra"])
  random_number = Enum.random(1..10)
  random_user = Enum.random(all_users)
  answer = i * random_number

  {:ok, card} =
    Cards.create_card(%{
      question: "What is #{i} * #{random_number} ??",
      answer: "#{answer}",
      category: category,
      tag: random_tag
    })

  Cards.add_card_to_user(random_user.id, card.id)
end)
