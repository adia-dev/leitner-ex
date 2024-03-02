defmodule LeitnerWeb.CardLiveTest do
  use LeitnerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Leitner.CardsFixtures
  import Leitner.AccountsFixtures

  @create_attrs %{
    tag: "some tag",
    category: :first,
    question: "some question",
    answer: "some answer"
  }
  @update_attrs %{
    tag: "some updated tag",
    category: :second,
    question: "some updated question",
    answer: "some updated answer"
  }
  @invalid_attrs %{tag: nil, category: nil, question: nil, answer: nil}

  defp create_card(_) do
    card = card_fixture()
    %{card: card}
  end

  describe "Index" do
    setup [:create_card]

    test "lists all cards", %{conn: conn, card: card} do
      {:ok, _index_live, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/cards")

      assert html =~ "Listing Cards"
      assert html =~ "Category"
      assert html =~ "Question"
      assert html =~ "Answer"
      assert html =~ "Tag"
    end

    test "saves new card", %{conn: conn} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/cards")

      assert index_live |> element("a", "New Card") |> render_click() =~
               "New Card"

      assert_patch(index_live, ~p"/cards/new")

      assert index_live
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#card-form", card: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cards")

      html = render(index_live)
      assert html =~ "Card created successfully"
      assert html =~ "some tag"
    end
  end

  describe "Show" do
    setup [:create_card]

    test "displays card", %{conn: conn, card: card} do
      {:ok, _show_live, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/cards/#{card}")

      assert html =~ "Show Card"
      assert html =~ card.tag
    end

    test "updates card within modal", %{conn: conn, card: card} do
      {:ok, show_live, _html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/cards/#{card}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Card"

      assert_patch(show_live, ~p"/cards/#{card}/show/edit")

      assert show_live
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#card-form", card: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cards/#{card}")

      html = render(show_live)
      assert html =~ "Card updated successfully"
      assert html =~ "some updated tag"
    end
  end
end
