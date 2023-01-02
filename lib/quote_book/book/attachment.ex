defmodule QuoteBook.Book.Attachment do
  @moduledoc """
  Вложение в сообщениях.

  Если вложение было скачано, то `path` указывает на локальный файл. Если не
  скачано, то это внешняя ссылка.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @attachment_types ~w(photo video audio audio_message doc link market market_album wall wall_reply sticker gift)a

  @type attachmment_type ::
          unquote(
            @attachment_types
            |> Enum.map_join(" | ", &inspect/1)
            |> Code.string_to_quoted!()
          )

  @type t :: %__MODULE__{
          id: non_neg_integer() | nil,
          message_id: non_neg_integer() | nil,
          path: String.t(),
          type: attachmment_type | nil,
          ext: String.t() | nil,
        }

  schema "attachments" do
    field :message_id, :id

    field :path, :string
    field :type, Ecto.Enum, values: @attachment_types
    field :ext, :string

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:path, :type, :ext])
    |> validate_required([:path, :type])
  end
end
