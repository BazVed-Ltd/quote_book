defmodule QuoteBookBot.Commands.SaveQuote do
  @moduledoc """
  /сьлржалсч [глубинность] — сохраняет пересланные сообщения как цитату.

  Глубинность указывает как глубоко необходимо подгружать вложенные сообщения. \
  Если глубинность равна нулю, то сохраняются только пересланные при сохранении \
  сообщения.
  """
  import VkBot.{CommandsManager, Request}
  require VkBot.CommandsManager

  alias QuoteBookBot.Utils.{Attachments, Links, ReplyMessages, UserLoader}

  defcommand request,
    predicate: [on_text: "/сьлржалсч", in: :chat] do
    message =
      request.message
      |> ReplyMessages.insert_reply_message()
      |> Attachments.insert_attachments()

    args = String.split(message["text"], " ")

    reply_text =
      with {:ok, chat} <-
             QuoteBook.Book.get_or_new_chat(message["peer_id"])
             |> QuoteBook.Book.create_or_update_chat(%{}),
           {:ok, _users} <-
             UserLoader.message_to_users_list(message)
             |> QuoteBook.Book.reject_exists_user()
             |> UserLoader.insert_new_users_data_to_db(),
           {:ok, deep} <- parse_deep_from_args(args),
           {:ok, message_quote} <- QuoteBook.Book.create_quote_from_message(message, deep) do
        """
        Добавил.
        #{Links.quote_link(chat, message_quote)}
        """
      else
        {:error, %Ecto.Changeset{} = changeset} -> error_message_from_changeset(changeset)
        {:error, message} when is_binary(message) -> message
      end

    reply_message(request, reply_text)
  end

  defp error_message_from_changeset(changeset) do
    changeset.errors
    |> Enum.into(%{})
    |> Map.values()
    |> Enum.map_join("\n", &elem(&1, 0))
    |> case do
      "" -> "Неизвестная ошибка. Сбрасываю ядерную боеголовку на разработчика"
      text -> text
    end
  end

  def parse_deep_from_args([_command]) do
    {:ok, :infinity}
  end

  def parse_deep_from_args([_command, deep_arg]) do
    case Integer.parse(deep_arg) do
      {deep, ""} ->
        {:ok, deep}

      _error ->
        {:error, "Вторым аргументом нужно указать число"}
    end
  end
end
