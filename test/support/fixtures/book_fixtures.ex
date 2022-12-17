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
      |> QuoteBook.Book.create_message()

    message
  end

  @doc """
  Generate a quote.
  """
  def quote_fixture(attrs \\ %{}) do
    {:ok, quote} =
      attrs
      |> Enum.into(%{

      })
      |> QuoteBook.Book.create_quote()

    quote
  end

  @doc """
  Generate a attachment.
  """
  def attachment_fixture(attrs \\ %{}) do
    {:ok, attachment} =
      attrs
      |> Enum.into(%{
        path: "some path",
        type: :photo
      })
      |> QuoteBook.Book.create_attachment()

    attachment
  end
end
