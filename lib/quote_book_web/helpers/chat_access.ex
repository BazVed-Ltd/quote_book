defmodule QuoteBookWeb.Helpers.ChatAccess do
  def on_mount(:default, _params, _session, socket) do
    user = socket.assigns.current_user
    chat = socket.assigns.chat

    if chat.id in user.chat_ids do
      {:cont, socket}
    else
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(
         :error,
         "У вас нет доступа к этому чату."
       )
       |> Phoenix.LiveView.redirect(to: "/")}
    end
  end
end
