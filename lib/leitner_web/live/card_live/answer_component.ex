defmodule LeitnerWeb.CardLive.AnswerComponent do
  use LeitnerWeb, :live_component
  alias LeitnerWeb.Clients.Cards.ApiClient

  alias Leitner.Cards

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <p class="text-lg font-semibold">Question</p>
      </.header>

      <.simple_form
        for={@form}
        id="card-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="guess"
      >
        <div>
          <p class="bg-gray-100 p-5 rounded-md italic"><%= @card.question %></p>
        </div>
        <.input field={@form[:guess]} type="textarea" label="Guess" />

        <ul class="flex items-center gap-2">
          <%= for tag <- String.split(@card.tag, ",") do %>
            <li class="bg-blue-200 text-blue-800 hover:bg-blue-300 hover:scale-105 cursor-pointer transition rounded-full px-2 text-sm">
              <p><%= tag %></p>
            </li>
          <% end %>
        </ul>

        <:actions>
          <.button phx-disable-with="Answering...">Answer Card</.button>
        </:actions>
        <%= if @reveal_card do %>
          <p class={[
            if(@valid_answer, do: "text-green-500", else: "text-red-500")
          ]}>
            Answer: <%= @card.answer %>
          </p>
          <.button
            phx-click="validate_anyway"
            type="button"
            phx-target={@myself}
            class="bg-red-500 hover:bg-red-600"
          >
            <.icon name="hero-exclamation-triangle" /> Force good answer
          </.button>
        <% else %>
          <.button
            phx-click="reveal_card"
            type="button"
            phx-target={@myself}
            class="bg-red-500 hover:bg-red-600"
          >
            <.icon name="hero-exclamation-triangle" /> Reveal Card
          </.button>
        <% end %>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{card: card} = assigns, socket) do
    changeset = Cards.change_card(card)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:reveal_card, false)
     |> assign(:valid_answer, false)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"card" => card_params}, socket) do
    changeset =
      socket.assigns.card
      |> Cards.change_card(card_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("validate", %{"card" => card_params}, socket) do
    changeset =
      socket.assigns.card
      |> Cards.change_card(card_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("reveal_card", _params, socket) do
    {:noreply, assign(socket, :reveal_card, true)}
  end

  @impl true
  def handle_event("validate_anyway", _params, socket) do
    next_category =
      Cards.Card.next_category(socket.assigns.card.category)

    ApiClient.update_card(socket.assigns.card.id, %{category: next_category})

    {:noreply,
     socket
     |> put_flash(:info, "Forced good answer !")
     |> push_patch(to: socket.assigns.patch)}
  end

  @impl true
  def handle_event("guess", %{"card" => %{"guess" => guess}}, socket) do
    case Cards.answer_card(socket.assigns.card, %{guess: guess}) do
      {:ok, card} ->
        notify_parent({:answered, card})

        ApiClient.answer_card(card.id, true)

        {:noreply,
         socket
         |> assign(:reveal_card, card.answer)
         |> put_flash(:info, "Good answer !")
         |> push_patch(to: socket.assigns.patch)}

      {:error, :wrong_answer, card} ->
        notify_parent({:answered, card})
        ApiClient.answer_card(card.id, false)

        {:noreply,
         socket
         |> put_flash(:error, "Wrong answer...")
         |> assign(:show_good_answer, card.answer)
         |> assign(:valid_answer, false)
         |> assign(:reveal_card, true)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not answer: #{reason}")}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
