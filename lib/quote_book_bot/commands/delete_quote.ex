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

  @time_for_deletion_in_seconds 1 * 24 * 60 * 60

  @succes_message "Цитата %1 успешно удалена!"
  @arg_error_message "Нужно указать айди удаляемой цитаты.\nДля справки используйте «/помощь удалить»."
  @wrong_id_error_message "Вы указали неправильный айди удаляемой цитаты."
  @deletion_time_error_message "Вы не можете удалить эту цитату. Она теперь часть истории."
  @permission_error_message "У вас нет прав на удаление этой цитаты."

  defcommand request,
    predicate: [on_text: "/удалить", in: :chat] do
    message = request.message

    reply_text =
      with {:ok, index} <- parse_args(message["text"]),
           quote_id = Book.quote_index_to_quote_id(message["peer_id"], index),
           {:ok, quote_message} <- Book.fetch_quote(message["peer_id"], quote_id),
           {:ok, deleted_quote} <- try_delete_quote(quote_message, message["from_id"]) do
        String.replace(@succes_message, "%1", Integer.to_string(deleted_quote.quote_id))
      else
        {:error, error} -> error
      end

    reply_message(request, reply_text)
  end

  defp parse_args(text) do
    args =
      text
      |> String.split(" ")

    case args do
      [_command] ->
        {:error, @arg_error_message}

      [_command, "п"] ->
        {:ok, -1}

      [_command, quote_id] ->
        parse_quote_id(quote_id)

      [_command | _rest] ->
        {:error, @arg_error_message}
    end
  end

  defp parse_quote_id(quote_id) do
    case Integer.parse(quote_id) do
      {id, ""} -> {:ok, id}
      _ -> {:error, @wrong_id_error_message}
    end
  end

  defp try_delete_quote(quote_message, user_id) do
    tasks = [
      Task.async(fn -> author?(quote_message, user_id) end),
      Task.async(fn -> admin?(quote_message, user_id) end),
      Task.async(fn -> created_in_the_last_five_minutes?(quote_message) end),
      Task.async(fn -> last_quote?(quote_message) end)
    ]

    case Task.await_many(tasks) do
      # is admin
      [_, true, _, true] ->
        {:ok, Book.delete_quote!(quote_message)}

      [_, true, _, false] ->
        {:ok, Book.mark_quote_as_deleted!(quote_message)}

      # is author
      [true, _, false, _] ->
        {:error, @deletion_time_error_message}

      [true, _, _, true] ->
        {:ok, Book.delete_quote!(quote_message)}

      [true, _, _, false] ->
        {:ok, Book.mark_quote_as_deleted!(quote_message)}

      # nor admin nor author
      [false, false, _, _] ->
        {:error, @permission_error_message}
    end
  end

  defp author?(quote_message, user_id) do
    quote_message.from_id == user_id
  end

  defp admin?(quote_message, user_id) do
    VkBot.Api.exec_method("messages.getConversationMembers", %{"peer_id" => quote_message.peer_id})
    |> Map.fetch!("items")
    |> Enum.find(%{}, fn user -> Map.fetch!(user, "member_id") == user_id end)
    |> Map.get("is_admin", false)
  end

  def created_in_the_last_five_minutes?(quote_message) do
    created = DateTime.from_naive!(quote_message.inserted_at, "Etc/UTC")
    now = DateTime.now!("Etc/UTC")

    DateTime.diff(now, created) < @time_for_deletion_in_seconds
  end

  defp last_quote?(quote_message) do
    Book.get_last_quote_id(quote_message.peer_id) == quote_message.quote_id
  end
end
