defmodule QuoteBookWeb.SignInLive do
  use QuoteBookWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, user_return_to: session["user_return_to"] || "/")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-3 flex flex-col">
      <div class="card mx-auto px-9">
        <h1 class="text-2xl text-center">Войти</h1>
        <div
          id="vk-login"
          class="mx-auto mt-5 max-w-full"
          phx-hook="vkLoginHook"
          phx-update="ignore"
          data-return-to={@user_return_to}
        >
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("error", message, socket) do
    {:noreply, Phoenix.LiveView.put_flash(socket, :error, message)}
  end
end
