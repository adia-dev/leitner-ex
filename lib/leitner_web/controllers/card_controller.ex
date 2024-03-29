defmodule LeitnerWeb.CardController do
  use LeitnerWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias LeitnerWeb.Schemas.CardAnswerRequest
  alias LeitnerWeb.Schemas.CardUpdateRequest
  alias LeitnerWeb.Schemas.CardCreateRequest
  alias LeitnerWeb.Schemas.CardResponse
  alias Leitner.Cards
  alias Leitner.Cards.Card

  action_fallback LeitnerWeb.FallbackController

  tags ["Cards"]

  operation :index,
    summary: "List cards",
    description: "Fetches a list of cards, optionally filtered by tags",
    parameters: [
      tags: [
        in: :query,
        description: "Comma-separated list of tags to filter by",
        type: :string,
        required: false
      ]
    ],
    responses: [
      ok: {"List of cards", "application/json", [CardResponse]}
    ]

  def index(conn, %{"tags" => tags}) when is_bitstring(tags),
    do: index(conn, %{"tags" => String.split(tags, ",")})

  def index(conn, params) do
    cards =
      case Map.get(params, "tags") do
        nil ->
          Cards.list_cards()

        tags ->
          Cards.list_cards_by_tags(tags)
      end

    render(conn, :index, cards: cards)
  end

  operation :create,
    summary: "Create a new card",
    description: "Creates a new card with the given parameters",
    request_body: {"Card parameters", "application/json", CardCreateRequest},
    responses: [
      created: {"Card created", "application/json", CardResponse}
    ]

  def create(conn, card_params) do
    card_changeset = Card.changeset(%Card{}, card_params)

    if card_changeset.valid? do
      case Cards.create_card(card_params) do
        {:ok, card} ->
          conn
          |> put_status(:created)
          |> render(:show, card: card)

        {:error, _} ->
          conn
          |> put_status(:internal_server_error)
      end
    else
      conn
      |> send_resp(:bad_request, "Incorrect request payload")
    end
  end

  operation :show,
    summary: "Get a single card",
    description: "Fetches a single card by its ID",
    parameters: [
      id: [
        in: :path,
        description: "Card ID",
        type: :string,
        required: true,
        example: "123e4567-e89b-12d3-a456-426614174000"
      ]
    ],
    responses: [
      ok: {"Card details", "application/json", CardResponse},
      not_found: {"Error message", "application/json", nil}
    ]

  def show(conn, %{"id" => id}) do
    case Cards.get_card(id) do
      nil ->
        send_resp(conn, :not_found, "No card found related with the id: #{id}")

      card ->
        render(conn, :show, card: card)
    end
  end

  operation :update,
    summary: "Update a card",
    description: "Updates a card's information by its ID",
    parameters: [
      id: [
        in: :path,
        description: "Card ID",
        type: :string,
        required: true,
        example: "123e4567-e89b-12d3-a456-426614174000"
      ]
    ],
    request_body: {"Card update parameters", "application/json", CardUpdateRequest},
    responses: [
      ok: {"Updated card", "application/json", CardResponse},
      not_found: {"Error message", "application/json", nil}
    ]

  def update(conn, %{"id" => id} = card_params) do
    card = Cards.get_card!(id)

    with {:ok, %Card{} = card} <- Cards.update_card(card, card_params) do
      render(conn, :show, card: card)
    end
  end

  operation :delete,
    summary: "Delete a card",
    description: "Deletes a card by its ID",
    parameters: [
      id: [
        in: :path,
        description: "Card ID",
        type: :string,
        required: true,
        example: "123e4567-e89b-12d3-a456-426614174000"
      ]
    ],
    responses: [
      no_content: "Card successfully deleted",
      not_found: {"Error message", "application/json", nil}
    ]

  def delete(conn, %{"id" => id}) do
    case Cards.get_card(id) do
      nil ->
        send_resp(conn, :not_found, "No card found related with the id: #{id}")

      card ->
        with {:ok, _} <- Cards.delete_card(card) do
          send_resp(conn, :no_content, "")
        end
    end
  end

  operation :answer,
    summary: "Answer a card",
    description:
      "Marks a card as answered and updates its category based on whether the answer was valid",
    parameters: [
      id: [
        in: :path,
        description: "Card ID",
        type: :string,
        required: true,
        example: "123e4567-e89b-12d3-a456-426614174000"
      ]
    ],
    request_body: {"Card answer parameters", "application/json", CardAnswerRequest},
    responses: [
      no_content: "Card category updated successfully",
      not_found: {"Error message", "application/json", nil},
      bad_request: {"Error message", "application/json", nil},
      internal_server_error: {"Error message", "application/json", nil}
    ]

  def answer(conn, %{"id" => id, "isValid" => is_valid}) when is_boolean(is_valid) do
    case Cards.get_card(id) do
      nil ->
        send_resp(conn, :not_found, "No card found related with the id: #{id}")

      card ->
        new_category =
          if is_valid do
            Card.next_category(card.category)
          else
            :first
          end

        next_answer_date = calculate_next_answer_date(card)

        case Cards.update_card(card, %{
               category: new_category,
               next_answer_date: next_answer_date,
               last_answered: DateTime.utc_now()
             }) do
          {:ok, _card} ->
            send_resp(conn, :no_content, "")

          {:error, _} ->
            send_resp(conn, :internal_server_error, "")
        end
    end
  end

  def answer(conn, _params),
    do: send_resp(conn, :bad_request, "Incorrect request payload")

  operation :quizz,
    summary: "Get a quizz",
    description: "Fetches a quizz of cards, optionally filtered by date",
    parameters: [
      date: [
        in: :query,
        description: "Date to filter by",
        type: :string,
        required: false,
        example: "2021-01-01"
      ]
    ],
    responses: [
      ok: {"Quizz of cards", "application/json", [CardResponse]},
      bad_request: {"Error message", "application/json", nil}
    ]

  def quizz(conn, %{"date" => date}) when is_bitstring(date) do
    if Regex.match?(~r/\d{4}-\d{2}-\d{2}/, date) do
      case Date.from_iso8601(date) do
        {:ok, date} ->
          date = NaiveDateTime.new!(date, ~T[00:00:00])
          cards = Cards.list_cards_by_date(date)

          render(conn, :index, cards: cards)

        {:error, _} ->
          send_resp(
            conn,
            :bad_request,
            "Incorrect request payload expected date in format YYYY-MM-DD"
          )
      end
    else
      send_resp(
        conn,
        :bad_request,
        "Incorrect request payload expected date in format YYYY-MM-DD"
      )
    end
  end

  def quizz(conn, %{"date" => date}) do
    case date do
      nil ->
        send_resp(
          conn,
          :bad_request,
          "Incorrect request payload expected date in format YYYY-MM-DD"
        )

      date ->
        cards = Cards.list_cards_by_date(date)

        render(conn, :quizz, cards: cards)
    end
  end

  @doc """
  Calculates the next date a card can be answered based on its category and last_answered date.

  ## Parameters

  - card: The card to calculate the next answer date for.
  """
  def calculate_next_answer_date(%Card{category: category, last_answered: last_answered}) do
    delay_days = category_to_delay_days(category)

    last_answered =
      if is_nil(last_answered) do
        DateTime.utc_now()
      else
        last_answered
      end

    next_answer_date = DateTime.add(last_answered, delay_days * 86_400, :second)
    next_answer_date
  end

  defp category_to_delay_days(category) do
    case category do
      :first -> 1
      :second -> 2
      :third -> 4
      :fourth -> 8
      :fifth -> 16
      :sixth -> 32
      :seventh -> 64
      :done -> 0
    end
  end
end
