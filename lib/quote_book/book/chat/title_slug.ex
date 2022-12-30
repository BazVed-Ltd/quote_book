defmodule QuoteBook.Book.Chat.TitleSlug do
  use EctoAutoslugField.Slug, from: :title, to: :slug, always_change: true
end
