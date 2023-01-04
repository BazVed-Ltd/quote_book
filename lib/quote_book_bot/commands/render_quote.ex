defmodule QuoteBookBot.Commands.RenderQuote do
  @moduledoc """
  /сь <id> — отправить картинку с цитатой
  """
  import VkBot.{CommandsManager, Request}
  require VkBot.CommandsManager

  defcommand request,
    predicate: [on_text: "/сь", in: :chat] do
    args =
      request.message
      |> Map.fetch!("text")
      |> String.split(" ")

    case args do
      [_command, id] ->
        quote_message = QuoteBook.Book.get_quote(request.message["peer_id"], String.to_integer(id))
        rendered_quote = render_quote(quote_message)
        reply_message(request, "", attachment: rendered_quote.vk_path)

      _ ->
        reply_message(request, help_text())
    end
  end

  defp help_text do
    "Вторым аргументом должен быть айди цитаты."
  end

  defp render_quote(quote_message) do
    QuoteBookBot.Utils.QuoteToPNG.convert(quote_message)
  end
end
