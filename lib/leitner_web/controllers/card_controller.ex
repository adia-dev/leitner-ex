defmodule LeitnerWeb.CardController do
  use LeitnerWeb, :controller

  alias Leitner.Cards
  alias Leitner.Cards.Card

  action_fallback LeitnerWeb.FallbackController

  def index(conn, %{"tag" => tag}) when is_bitstring(tag),
    do: index(conn, %{"tag" => String.split(tag, ",")})

  def index(conn, params) do
    cards =
      case Map.get(params, "tag") do
        nil ->
          Cards.list_cards()

        tags ->
          Cards.list_cards_by_tags(tags)
      end

    render(conn, :index, cards: cards)
  end

  def create(conn, %{"card" => card_params}) do
    with {:ok, %Card{} = card} <- Cards.create_card(card_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/cards/#{card}")
      |> render(:show, card: card)
    end
  end

  def show(conn, %{"id" => id}) do
    card = Cards.get_card!(id)
    render(conn, :show, card: card)
  end

  def update(conn, %{"id" => id, "card" => card_params}) do
    card = Cards.get_card!(id)

    with {:ok, %Card{} = card} <- Cards.update_card(card, card_params) do
      render(conn, :show, card: card)
    end
  end

  def delete(conn, %{"id" => id}) do
    card = Cards.get_card!(id)

    with {:ok, %Card{}} <- Cards.delete_card(card) do
      send_resp(conn, :no_content, "")
    end
  end
end
