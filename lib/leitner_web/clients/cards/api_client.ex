defmodule LeitnerWeb.Clients.Cards.ApiClient do
  @moduledoc """
  API Client for interacting with the Cards API.
  """
  require Logger
  alias Leitner.User.Cards.UserCard
  alias Leitner.Cards.Card

  @api_base_url "http://localhost:4000/api"
  @endpoints [
    list: "/cards",
    create: "/cards",
    update: "/cards/%s",
    delete: "/cards/%s",
    add_card_to_user: "/user_cards",
    update_card_review: "/user_cards/%s",
    remove_mastered_card: "/user_cards/%s",
    list_user_cards: "/user_cards",
    list_cards_for_review: "/user_cards/review"
  ]

  def list_cards(tag \\ nil) do
    url =
      (@api_base_url <> get_endpoint(:list))
      |> maybe_add_query_param("tag", tag)

    HTTPoison.get(url)
    |> handle_response(as: [%Card{}])
  end

  def get_card(id) do
    url = "#{@api_base_url}/cards/#{id}"

    HTTPoison.get(url)
    |> handle_response(as: %Card{})
  end

  def get_card!(id) do
    {:ok, card} = get_card(id)
    card
  end

  def create_card(attrs) do
    url = "#{@api_base_url}#{@endpoints[:create]}"

    HTTPoison.post(url, Poison.encode!(attrs))
    |> handle_response(as: %Card{})
  end

  def update_card(card_id, attrs) do
    url = "#{@api_base_url}/cards/#{card_id}"

    HTTPoison.put(url, Poison.encode!(attrs))
    |> handle_response(as: %Card{})
  end

  def delete_card(card_id) do
    url = "#{@api_base_url}/cards/#{card_id}"

    HTTPoison.delete(url)
    |> handle_response()
  end

  def add_card_to_user(user_id, card_id) do
    url = "#{@api_base_url}#{@endpoints[:add_card_to_user]}"
    body = %{user_id: user_id, card_id: card_id}

    HTTPoison.post(url, Poison.encode!(body))
    |> handle_response()
  end

  def update_card_review(user_id, card_id, correct) do
    url = "#{@api_base_url}/user_cards/#{user_id}"
    body = %{card_id: card_id, correct: correct}

    HTTPoison.put(url, Poison.encode!(body))
    |> handle_response()
  end

  def remove_mastered_card(user_card_id) do
    url = "#{@api_base_url}/user_cards/#{user_card_id}"

    HTTPoison.delete(url)
    |> handle_response()
  end

  def list_user_cards(user_id) do
    url = "#{@api_base_url}/user_cards?user_id=#{user_id}"

    HTTPoison.get(url)
    |> handle_response(as: [%UserCard{}])
  end

  def list_cards_for_review(user_id) do
    url = "#{@api_base_url}/user_cards/review?user_id=#{user_id}"

    HTTPoison.get(url)
    |> handle_response(as: [%UserCard{}])
  end

  defp handle_response(
         {:ok, %HTTPoison.Response{status_code: status_code, body: body}},
         opts \\ [keys: :atoms]
       )
       when status_code >= 200 and status_code < 300 do
    if Keyword.has_key?(opts, :as) do
      {:ok, Poison.decode!(body, opts)}
    else
      {:ok, nil}
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status, body: body}}, _) do
    Logger.error("Request failed with status code #{status}: #{body}")
    {:error, %{status: status, body: body}}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}, _) do
    Logger.error("HTTP request failed: #{inspect(reason)}")
    {:error, reason}
  end

  defp maybe_add_query_param(url, name, value) when is_list(value),
    do: url <> "?" <> name <> "=" <> Enum.join(value, ",")

  defp maybe_add_query_param(url, name, value) when is_bitstring(value) or is_integer(value),
    do: url <> "?" <> name <> "=" <> "#{value}"

  defp maybe_add_query_param(url, _name, _value), do: url

  defp get_endpoint(endpoint) when is_atom(endpoint), do: Keyword.get(@endpoints, endpoint)

  defp get_endpoint(endpoint) when is_bitstring(endpoint),
    do: Keyword.get(@endpoints, String.to_atom(endpoint))

  defp get_endpoint(_endpoint), do: nil
end
