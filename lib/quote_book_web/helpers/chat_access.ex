defmodule QuoteBookWeb.Helpers.ChatAccess do
  use Phoenix.VerifiedRoutes, endpoint: QuoteBookWeb.Endpoint, router: QuoteBookWeb.Router

  def on_mount(:default, _params, _session, socket) do
    user = socket.assigns.user
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
       |> Phoenix.LiveView.redirect(to: ~p"/")}
    end
  end
end
