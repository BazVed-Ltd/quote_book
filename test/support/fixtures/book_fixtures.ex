defmodule QuoteBook.BookFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuoteBook.Book` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        from_id: 42,
        peer_id: 42,
        text: "some text"
      })
      |> QuoteBook.Book.create_quote_from_message()

    message
  end

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      QuoteBook.Book.get_or_new_chat(1)
      |> QuoteBook.Book.create_or_update_chat(
        attrs
        |> Enum.into(%{
          id: 1,
          title: "some title"
        })
      )

    chat
  end
end
