defmodule QuoteBook.Book.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attachments" do
    field :message_id, :id

    field :path, :string
    field :type, Ecto.Enum, values: [:photo, :video, :audio, :doc, :link, :market, :market_album, :wall, :wall_reply, :sticker, :gift]

    timestamps()
  end

  @doc false
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:path, :type])
    |> validate_required([:path, :type])
  end
end
