defmodule LeitnerWeb.CardControllerTest do
  use LeitnerWeb.ConnCase

  import Leitner.CardsFixtures

  alias Leitner.Cards.Card

  @create_attrs %{
    tag: "some tag",
    category: :first,
    question: "some question",
    answer: "some answer"
  }

  @update_attrs %{
    question: "some updated question"
  }

  @invalid_attrs %{tag: nil, category: nil, question: nil, answer: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all cards", %{conn: conn} do
      conn = get(conn, ~p"/api/cards")
      assert json_response(conn, 200) == []
    end
  end

  describe "create card" do
    test "renders card when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/cards", card: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, ~p"/api/cards/#{id}")

      %{tag: tag, answer: answer, category: category} = @create_attrs

      category =
        category
        |> Atom.to_string()
        |> String.upcase()


      assert %{
               "id" => ^id,
               "tag" => ^tag,
               "answer" => ^answer,
               "category" => ^category,
               "question" => "some question"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/cards", card: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update card" do
    setup [:create_card]

    test "renders card when data is valid", %{
      conn: conn,
      card: %Card{id: id, tag: tag, category: category, answer: answer} = card
    } do
      conn = put(conn, ~p"/api/cards/#{card}", card: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, ~p"/api/cards/#{id}")

      category =
        card.category
        |> Atom.to_string()
        |> String.upcase()

      assert %{
               "id" => ^id,
               "tag" => ^tag,
               "answer" => ^answer,
               "category" => ^category,
               "question" => "some updated question"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, card: card} do
      conn = put(conn, ~p"/api/cards/#{card}", card: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete card" do
    setup [:create_card]

    test "deletes chosen card", %{conn: conn, card: card} do
      conn = delete(conn, ~p"/api/cards/#{card}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/cards/#{card}")
      end
    end
  end

  defp create_card(_) do
    card = card_fixture()
    %{card: card}
  end
end
