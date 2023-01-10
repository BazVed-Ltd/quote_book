defmodule QuoteBook.Guardian do
  use Guardian, otp_app: :quote_book

  def subject_for_token(id, _claims) when is_integer(id) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    throw("Invalid object")
  end

  def resource_from_claims(%{"sub" => id}) do
    {:ok, id}
  end

  def resource_from_claims(_claims) do
    throw("Invalid subbject")
  end
end
