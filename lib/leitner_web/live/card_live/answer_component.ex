defmodule LeitnerWeb.CardLive.AnswerComponent do
  use LeitnerWeb, :live_component

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

  def handle_event("guess", %{"card" => %{"guess" => guess}}, socket) do
    case Cards.answer_card(socket.assigns.card, %{guess: guess}) do
      {:ok, card} ->
        notify_parent({:answered, card})

        {:noreply,
         socket
         |> put_flash(:info, "Good answer !!")
         |> push_patch(to: socket.assigns.patch)}

      {:error, :wrong_answer, card} ->
        {:noreply,
         socket
         |> put_flash(:error, "Wrong answer...")
         |> push_patch(to: socket.assigns.patch)}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not answer: #{reason}")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
