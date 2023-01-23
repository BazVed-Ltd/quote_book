defmodule QuoteBookWeb.SignInLive do
  use QuoteBookWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-3 flex flex-col">
      <div class="card mx-auto px-9">
        <h1 class="text-2xl text-center">Войти</h1>
        <div id="vk-login" class="mx-auto mt-5 max-w-full" phx-hook="vkLoginHook" phx-update="ignore"></div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("error", message, socket) do
    {:noreply, Phoenix.LiveView.put_flash(socket, :error, message)}
  end
end
