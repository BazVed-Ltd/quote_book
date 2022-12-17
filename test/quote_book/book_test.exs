defmodule QuoteBook.BookTest do
  use QuoteBook.DataCase

  alias QuoteBook.Book

  describe "messages" do
    alias QuoteBook.Book.Message

    import QuoteBook.BookFixtures

    @invalid_attrs %{from_id: nil, peer_id: nil, text: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Book.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Book.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{from_id: 42, peer_id: 42, text: "some text"}

      assert {:ok, %Message{} = message} = Book.create_message(valid_attrs)
      assert message.from_id == 42
      assert message.peer_id == 42
      assert message.text == "some text"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Book.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{from_id: 43, peer_id: 43, text: "some updated text"}

      assert {:ok, %Message{} = message} = Book.update_message(message, update_attrs)
      assert message.from_id == 43
      assert message.peer_id == 43
      assert message.text == "some updated text"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Book.update_message(message, @invalid_attrs)
      assert message == Book.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Book.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Book.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Book.change_message(message)
    end
  end

  describe "quotes" do
    alias QuoteBook.Book.Quote

    import QuoteBook.BookFixtures

    @invalid_attrs %{}

    test "list_quotes/0 returns all quotes" do
      quote = quote_fixture()
      assert Book.list_quotes() == [quote]
    end

    test "get_quote!/1 returns the quote with given id" do
      quote = quote_fixture()
      assert Book.get_quote!(quote.id) == quote
    end

    test "create_quote/1 with valid data creates a quote" do
      valid_attrs = %{}

      assert {:ok, %Quote{} = quote} = Book.create_quote(valid_attrs)
    end

    test "create_quote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Book.create_quote(@invalid_attrs)
    end

    test "update_quote/2 with valid data updates the quote" do
      quote = quote_fixture()
      update_attrs = %{}

      assert {:ok, %Quote{} = quote} = Book.update_quote(quote, update_attrs)
    end

    test "update_quote/2 with invalid data returns error changeset" do
      quote = quote_fixture()
      assert {:error, %Ecto.Changeset{}} = Book.update_quote(quote, @invalid_attrs)
      assert quote == Book.get_quote!(quote.id)
    end

    test "delete_quote/1 deletes the quote" do
      quote = quote_fixture()
      assert {:ok, %Quote{}} = Book.delete_quote(quote)
      assert_raise Ecto.NoResultsError, fn -> Book.get_quote!(quote.id) end
    end

    test "change_quote/1 returns a quote changeset" do
      quote = quote_fixture()
      assert %Ecto.Changeset{} = Book.change_quote(quote)
    end
  end
end
