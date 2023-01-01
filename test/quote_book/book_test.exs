defmodule QuoteBook.BookTest do
  use QuoteBook.DataCase

  alias QuoteBook.Book

  describe "attachments" do
    alias QuoteBook.Book.Attachment

    import QuoteBook.BookFixtures

    @invalid_attrs %{path: nil, type: nil}

    test "list_attachments/0 returns all attachments" do
      attachment = attachment_fixture()
      assert Book.list_attachments() == [attachment]
    end

    test "get_attachment!/1 returns the attachment with given id" do
      attachment = attachment_fixture()
      assert Book.get_attachment!(attachment.id) == attachment
    end

    test "create_attachment/1 with valid data creates a attachment" do
      valid_attrs = %{path: "some path", type: :photo}

      assert {:ok, %Attachment{} = attachment} = Book.create_attachment(valid_attrs)
      assert attachment.path == "some path"
      assert attachment.type == :photo
    end

    test "create_attachment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Book.create_attachment(@invalid_attrs)
    end

    test "update_attachment/2 with valid data updates the attachment" do
      attachment = attachment_fixture()
      update_attrs = %{path: "some updated path", type: :video}

      assert {:ok, %Attachment{} = attachment} = Book.update_attachment(attachment, update_attrs)
      assert attachment.path == "some updated path"
      assert attachment.type == :video
    end

    test "update_attachment/2 with invalid data returns error changeset" do
      attachment = attachment_fixture()
      assert {:error, %Ecto.Changeset{}} = Book.update_attachment(attachment, @invalid_attrs)
      assert attachment == Book.get_attachment!(attachment.id)
    end

    test "delete_attachment/1 deletes the attachment" do
      attachment = attachment_fixture()
      assert {:ok, %Attachment{}} = Book.delete_attachment(attachment)
      assert_raise Ecto.NoResultsError, fn -> Book.get_attachment!(attachment.id) end
    end

    test "change_attachment/1 returns a attachment changeset" do
      attachment = attachment_fixture()
      assert %Ecto.Changeset{} = Book.change_attachment(attachment)
    end
  end

  describe "chats" do
    alias QuoteBook.Book.Chat

    import QuoteBook.BookFixtures

    @invalid_attrs %{id: nil}

    test "list_chats/0 returns all chats" do
      chat = chat_fixture()
      assert Book.list_chats() == [chat]
    end

    test "get_chat!/1 returns the chat with given id" do
      chat = chat_fixture()
      assert Book.get_chat!(chat.id) == chat
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Chat{} = chat} = Book.create_or_update_chat(chat, update_attrs)
      assert chat.title == "some updated title"
    end

    test "update_chat/2 with invalid data returns error changeset" do
      chat = chat_fixture()
      assert {:error, %Ecto.Changeset{}} = Book.create_or_update_chat(chat, @invalid_attrs)
      assert chat == Book.get_chat!(chat.id)
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = Book.change_chat(chat)
    end
  end
end
