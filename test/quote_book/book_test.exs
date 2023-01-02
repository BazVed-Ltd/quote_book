defmodule QuoteBook.BookTest do
  use QuoteBook.DataCase

  alias QuoteBook.Book

  describe "chats" do
    alias QuoteBook.Book.Chat

    import QuoteBook.BookFixtures

    test "list_chats/0 returns all chats" do
      chat = chat_fixture()
      assert Book.list_chats() == [chat]
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Chat{} = chat} = Book.create_or_update_chat(chat, update_attrs)
      assert chat.title == "some updated title"
    end
  end
end
