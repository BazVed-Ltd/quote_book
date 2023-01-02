defmodule QuoteBookBot.Commands.Help do
  @moduledoc """
  /помощь [команда] — выводит краткое описание всех команд или подробное \
  описание одной команды.
  """
  import VkBot.{CommandsManager, Request}
  require VkBot.CommandsManager

  defcommand request,
    predicate: [on_text: "/помощь", in: :chat] do
    args =
      request.message
      |> Map.fetch!("text")
      |> String.split(" ")

    text =
      case args do
        [_help] -> help_text()
        [_help, command] -> help_text(command)
        [_help, command | _other] -> "Попробуйте «/помощь #{command}»"
      end

    reply_message(request, text, disable_mentions: 1)
  end

  defp help_text do
    text =
      QuoteBookBot.Bot.commands()
      |> Enum.map_join("\n", fn module ->
        module
        |> get_module_doc()
        |> String.split("\n")
        |> Enum.at(0)
      end)

    text <> "\n\nPowered by [club209871027|Grand Catware Server]"
  end

  defp help_text(command) do
    QuoteBookBot.Bot.commands()
    |> Enum.find_value("Нет такой команды!", fn module ->
      doc = get_module_doc(module)
      first_word = doc |> String.split(" ") |> Enum.at(0)
      if String.bag_distance(first_word, command) > 0.7, do: doc
    end)
  end

  defp get_module_doc(module) do
    {:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, _} = Code.fetch_docs(module)
    module_doc
  end
end
