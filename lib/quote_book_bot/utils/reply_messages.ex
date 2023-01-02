defmodule QuoteBookBot.Utils.ReplyMessages do
  @moduledoc """
  API ВКонтакте в поле `reply_message` возвращает огрызок сообщения.
  `insert_reply_message/1` восстанавливает дерево пересланных сообщений полностью.
  """
  @spec insert_reply_message(map()) :: map()
  @doc """
  Возвращает сообщение с восстановленным деревом пересланных сообщений.
  """
  def insert_reply_message(%{"reply_message" => reply_message} = message) do
    conversation_message_id = reply_message["conversation_message_id"]
    peer_id = message["peer_id"]

    result_message =
      VkBot.Api.exec_method("messages.getByConversationMessageId", %{
        "conversation_message_ids" => conversation_message_id,
        "peer_id" => peer_id
      })
      |> Map.fetch!("items")
      |> List.first()
      |> insert_reply_message()

    message
    |> Map.put("reply_message", result_message)
  end

  def insert_reply_message(message) do
    message
  end
end
