defmodule QuoteBookBot.Commands.AddCoverToChat do
  import VkBot.CommandsManager
  require VkBot.CommandsManager

  alias QuoteBook.Book
  alias QuoteBookBot.Utils.Attachments

  defcommand request,
    predicate: [on_text: "/обложка", in: :chat],
    permissions: [only_admin: true] do
    message = request.message

    with [vk_attachment] <- Map.fetch!(message, "attachments"),
         att_type = Map.fetch!(vk_attachment, "type"),
         true <-
           att_type == "photo" || (att_type == "doc" && vk_attachment[att_type]["ext"] == "gif") do
      %{path: path} =
        vk_attachment
        |> Attachments.load_attachment()

      Book.append_chat_cover(message["peer_id"], path)
      reply_message(request, "Готово")
    else
      _error -> reply_message(request, "Прикрепи одну ГИФКУ или КАРТИНКУ")
    end
  end
end
