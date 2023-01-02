defmodule QuoteBookBot.Commands.DeleteQuote do
  @moduledoc """
  /удалить <id|п> — удаляет цитату.

  Удалять можно только свои цитаты. Админ может удалить любую цитату. \
  Поддерживаются отрицательные индексы. \
  Если вместо id указать «п», то удалится последняя цитата.
  """
  import VkBot.{CommandsManager, Request}
  require VkBot.CommandsManager

  alias QuoteBook.Book

  defcommand request,
    predicate: [on_text: "/удалить", in: :chat] do
    %{"peer_id" => peer_id, "from_id" => from_id, "text" => text} = request.message

    args =
      text
      |> String.split(" ")

    is_admin =
      VkBot.Api.exec_method("messages.getConversationMembers", %{"peer_id" => peer_id})
      |> Map.fetch!("items")
      |> Enum.find(%{}, fn user -> Map.fetch!(user, "member_id") == from_id end)
      |> Map.get("is_admin", false)

    case args do
      [_command] ->
        :help

      [_command, "п"] ->
        if is_admin do
          Book.maybe_delete_quote_by_admin(peer_id, -1)
        else
          Book.maybe_delete_quote(peer_id, -1, from_id)
        end

      [_command, quote_id] ->
        quote_id = String.to_integer(quote_id)
        if is_admin do
          Book.maybe_delete_quote_by_admin(peer_id, quote_id)
        else
          Book.maybe_delete_quote(peer_id, quote_id, from_id)
        end
      [_command | _rest] ->
        :help
    end
    |> case do
      :help ->
        reply_message(
          request,
          """
          Укажите номер цитаты, которую хотите удалить.
          Для удаления последней созданной цитаты используйте «/удалить п»
          """
        )

      :nothing ->
        reply_message(request, "Не могу удалить эту цитату (возможно не хватает прав)")

      :deleted ->
        reply_message(request, "Готово")
    end
  end
end
