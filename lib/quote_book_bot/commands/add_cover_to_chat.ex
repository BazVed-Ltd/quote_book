defmodule QuoteBookBot.Commands.AddCoverToChat do
  use VkBot.CommandsManager

  alias QuoteBook.Book
  alias QuoteBookBot.Utils.Attachments

  defcommand event, on_text: "/обложка" do
    message =
      event
      |> fetch_message()

    with [vk_attachment] <- Map.fetch!(message, "attachments"),
         att_type = Map.fetch!(vk_attachment, "type"),
         true <-
           att_type == "photo" || (att_type == "doc" && vk_attachment[att_type]["ext"] == "gif") do
      %{path: path} =
        vk_attachment
        |> Attachments.load_attachment()

      Book.append_chat_cover(message["peer_id"], path)
      {:ok, "ok"}
    else
      _error -> {:ok, "Прикрепи одну ГИФКУ или КАРТИНКУ"}
    end
  end
end
