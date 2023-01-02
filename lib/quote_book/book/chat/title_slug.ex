defmodule QuoteBook.Book.Chat.TitleSlug do
  @moduledoc false
  use EctoAutoslugField.Slug, from: :title, to: :slug, always_change: true
end
