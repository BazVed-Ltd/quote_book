defmodule QuoteBook.Book.RenderedQuote do
  @moduledoc """
  Отрендеренная цитата.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "rendered_quotes" do
    field :local_path, :string
    field :vk_path, :string

    timestamps()
  end

  @doc false
  def changeset(rendered_quote, attrs) do
    rendered_quote
    |> cast(attrs, [:id, :local_path, :vk_path])
    |> validate_required([:id, :local_path, :vk_path])
  end
end
