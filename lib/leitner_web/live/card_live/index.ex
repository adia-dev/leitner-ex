defmodule LeitnerWeb.CardLive.Index do
  alias LeitnerWeb.Clients.Cards.ApiClient
  use LeitnerWeb, :live_view

  alias Leitner.Cards
  alias Leitner.Cards.Card

  @impl true
  def mount(%{"tag" => tags}, session, socket) when is_list(tags) do
    tag = Enum.join(tags, ",")
    mount(%{"tag" => tag}, session, socket)
  end

  @impl true
  def mount(%{"tag" => tag}, _session, socket) when is_bitstring(tag) do
    case ApiClient.list_cards(tag) do
      {:ok, cards} ->
        {:ok, stream(socket, :cards, cards)}

      {:error, _reason} ->
        {:ok, stream(socket, :cards, [])}
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    case ApiClient.list_cards() do
      {:ok, cards} ->
        {:ok, stream(socket, :cards, cards)}

      {:error, _reason} ->
        {:ok, stream(socket, :cards, [])}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Card")
    |> assign(:card, ApiClient.get_card!(id))
  end

  defp apply_action(socket, :answer, %{"id" => id}) do
    socket
    |> assign(:page_title, "Answer Card")
    |> assign(:card, ApiClient.get_card!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Card")
    |> assign(:card, %Card{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Cards")
    |> assign(:card, nil)
  end

  @impl true
  def handle_info({LeitnerWeb.CardLive.FormComponent, {:saved, card}}, socket) do
    {:noreply, stream_insert(socket, :cards, card)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    card = ApiClient.get_card!(id)
    {:ok, _} = ApiClient.delete_card(card.id)

    {:noreply, stream_delete(socket, :cards, card)}
  end
end
