defmodule Leitner.CardsTest do
  use Leitner.DataCase

  alias Leitner.Cards

  describe "cards" do
    alias Leitner.Cards.Card

    import Leitner.CardsFixtures

    @invalid_attrs %{tag: nil, category: nil, question: nil, answer: nil}

    test "list_cards/0 returns all cards" do
      card = card_fixture()
      assert Cards.list_cards() == [card]
    end

    test "get_card!/1 returns the card with given id" do
      card = card_fixture()
      assert Cards.get_card!(card.id) == card
    end

    test "create_card/1 with valid data creates a card" do
      valid_attrs = %{
        tag: "some tag",
        category: :first,
        question: "some question",
        answer: "some answer"
      }

      assert {:ok, %Card{} = card} = Cards.create_card(valid_attrs)
      assert card.tag == "some tag"
      assert card.category == :first
      assert card.question == "some question"
      assert card.answer == "some answer"
    end

    test "create_card/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cards.create_card(@invalid_attrs)
    end

    test "update_card/2 with valid data updates the card" do
      card = card_fixture()

      update_attrs = %{
        tag: "some updated tag",
        category: :second,
        question: "some updated question",
        answer: "some updated answer"
      }

      assert {:ok, %Card{} = card} = Cards.update_card(card, update_attrs)
      assert card.tag == "some updated tag"
      assert card.category == :second
      assert card.question == "some updated question"
      assert card.answer == "some updated answer"
    end

    test "update_card/2 with invalid data returns error changeset" do
      card = card_fixture()
      assert {:error, %Ecto.Changeset{}} = Cards.update_card(card, @invalid_attrs)
      assert card == Cards.get_card!(card.id)
    end

    test "answer_cards/3 mastered card returns error" do
      card = mastered_card_fixture()

      assert {:error, :already_mastered} =
               Cards.answer_card(card, %{guess: "lolololo"})

      assert card.category == :done
    end

    test "answer_cards/3 with invalid payload returns error" do
      card = card_fixture()

      assert {:error, :missing_mandatory_field_guess} =
               Cards.answer_card(card, %{answer: "invalid key"})
    end

    test "answer_cards/3 with valid guess returns a ok" do
      card = card_fixture()
      assert {:ok, card} = Cards.answer_card(card, %{guess: "some answer"})
    end


    test "delete_card/1 deletes the card" do
      card = card_fixture()
      assert {:ok, %Card{}} = Cards.delete_card(card)
      assert_raise Ecto.NoResultsError, fn -> Cards.get_card!(card.id) end
    end

    test "change_card/1 returns a card changeset" do
      card = card_fixture()
      assert %Ecto.Changeset{} = Cards.change_card(card)
    end
  end
end
