defmodule QuoteBook.Guardian do
  use Guardian, otp_app: :quote_book

  def subject_for_token(%QuoteBook.Book.User{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    throw("Invalid object")
  end

  def resource_from_claims(%{"sub" => id}) do
    {:ok, QuoteBook.Book.get_user!(id)}
  end

  def resource_from_claims(_claims) do
    throw("Invalid subbject")
  end
end
