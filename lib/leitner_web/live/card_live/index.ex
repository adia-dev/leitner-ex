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
          Enum.map(cards, &(&1.category |> String.capitalize()))
          |> Enum.uniq()

        {:ok,
         stream(socket, :cards, cards)
         |> assign(:all_tags, all_tags)
         |> assign(:tags, tags)
         |> assign(:show_ready_to_answer, false)}

      {:error, _reason} ->
        {:ok, stream(socket, :cards, [])}
    end
  end

  @impl true
  def mount(_params, session, socket) do
    mount(%{"tags" => []}, session, socket)
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

  @impl true
  def handle_event("toggle_ready_to_answer", _params, socket) do
    new_state = not socket.assigns.show_ready_to_answer
    tags = socket.assigns.tags || ""

    cards = fetch_cards(tags, new_state)

    {:noreply,
     socket
     |> stream(:cards, cards)
     |> assign(:show_ready_to_answer, new_state)
     |> assign(:cards, cards)}
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

  @doc """
  Calculates the time until the card can be answered again and formats it for display.

  ## Parameters

  - next_answer_date: The DateTime when the card can next be answered.
  """
  def format_time_until_next_answer(nil), do: "Ready to answer"

  def format_time_until_next_answer(next_answer_date_string) do
    case DateTime.from_iso8601(next_answer_date_string) do
      {:ok, next_answer_date, _offset} ->
        current_time = DateTime.utc_now()
        diff_seconds = DateTime.diff(next_answer_date, current_time, :second)

        cond do
          diff_seconds <= 0 ->
            "Ready to answer"

          diff_seconds < 86_400 ->
            hours = div(diff_seconds, 3600)
            "#{hours}h"

          true ->
            days = div(diff_seconds, 86_400)
            "#{days}d"
        end

      :error ->
        "Invalid date"
    end
  end

  defp ready_to_answer?(%Card{next_answer_date: nil}), do: true

  defp ready_to_answer?(%Card{next_answer_date: next_answer_date_string})
       when is_bitstring(next_answer_date_string) do
    current_time = DateTime.utc_now()

    case DateTime.from_iso8601(next_answer_date_string) do
      {:ok, next_answer_date, _} ->
        DateTime.compare(current_time, next_answer_date) != :gt

      :error ->
        false
    end
  end

  defp ready_to_answer?(%Card{next_answer_date: next_answer_date}),
    do: DateTime.utc_now() |> DateTime.compare(next_answer_date) != :lt

  defp fetch_cards(tags, show_ready_to_answer) do
    case ApiClient.list_cards(tags) do
      {:ok, cards} when show_ready_to_answer ->
        Enum.filter(cards, &ready_to_answer?(&1))

      {:ok, cards} ->
        cards

      {:error, _reason} ->
        []
    end
  end
end
