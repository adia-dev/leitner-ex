defmodule LeitnerWeb.CardLive.Index do
  alias LeitnerWeb.Clients.Cards.ApiClient
  use LeitnerWeb, :live_view

  alias Leitner.Cards.Card

  @impl true
  def mount(%{"tags" => tags}, session, socket) when is_list(tags) do
    tags = Enum.join(tags, ",")
    mount(%{"tags" => tags}, session, socket)
  end

  @impl true
  def mount(%{"tags" => tags}, _session, socket) when is_bitstring(tags) do
    case ApiClient.list_cards(tags) do
      {:ok, cards} ->
        all_tags =
          Enum.map(cards, &(Atom.to_string(&1.category) |> String.capitalize()))
          |> Enum.uniq()

        {:ok, stream(socket, :cards, cards) |> assign(:all_tags, all_tags)}

      {:error, _reason} ->
        {:ok, stream(socket, :cards, [])}
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    case ApiClient.list_cards() do
      {:ok, cards} ->
        all_tags =
          Enum.map(cards, &(&1.category |> String.capitalize()))
          |> Enum.uniq()

        {:ok, stream(socket, :cards, cards) |> assign(:all_tags, all_tags)}

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
  def handle_info({LeitnerWeb.CardLive.AnswerComponent, {:answered, card}}, socket) do
    {:noreply, stream_insert(socket, :cards, card)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    card = ApiClient.get_card!(id)
    {:ok, _} = ApiClient.delete_card(card.id)

    {:noreply, stream_delete(socket, :cards, card)}
  end

  defp format_category(category) when is_atom(category), do: category
  defp format_category(category), do: String.downcase(category) |> String.to_atom()

  defp category(assigns) do
    ~H"""
    <%= case format_category(@category) do %>
      <% :first -> %>
        <span class="text-red-500">🔥</span>
      <% :second -> %>
        <span class="text-red-500">🔥🔥</span>
      <% :third -> %>
        <span class="text-red-500">🔥🔥🔥</span>
      <% :fourth -> %>
        <span class="text-red-500">🔥🔥🔥🔥</span>
      <% :fifth -> %>
        <span class="text-red-500">🔥🔥🔥🔥🔥</span>
      <% :sixth -> %>
        <span class="text-red-500">🔥🔥🔥🔥🔥🔥</span>
      <% :seventh -> %>
        <span class="text-red-500">🔥🔥🔥🔥🔥🔥🔥</span>
      <% :done -> %>
        <span class="text-green-500">✅</span>
      <% _ -> %>
        <span class="text-green-500"></span>
    <% end %>
    """
  end

  def cards_list(assigns) do
    ~H"""
    <div id={@id} class="flex flex-wrap -m-4" phx-update="stream">
      <%= for {card_id, card} <- @cards do %>
        <div id={card_id} class="p-4 md:w-1/2 lg:w-1/2 mt-5">
          <%= render_slot(@inner_block, card) %>
        </div>
      <% end %>
    </div>
    """
  end
end
