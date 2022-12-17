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
end
