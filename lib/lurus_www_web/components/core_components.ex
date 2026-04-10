defmodule LurusWwwWeb.CoreComponents do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  attr :flash, :map, required: true

  def flash_group(assigns) do
    ~H"""
    <.flash kind={:info} flash={@flash} />
    <.flash kind={:error} flash={@flash} />
    """
  end

  attr :kind, :atom, required: true
  attr :flash, :map, required: true
  attr :rest, :global

  def flash(assigns) do
    msg = Phoenix.Flash.get(assigns.flash, assigns.kind)
    assigns = assign(assigns, :msg, msg)

    ~H"""
    <div
      :if={@msg}
      id={"flash-#{@kind}"}
      class="fixed top-4 right-4 z-[100] max-w-sm rounded-lg px-4 py-3 text-sm shadow-lg"
      style={
        if @kind == :info,
          do: "background:var(--color-surface-overlay);border:1px solid rgba(0,240,255,0.2);color:var(--color-text-primary);",
          else: "background:rgba(127,29,29,0.8);border:1px solid rgba(220,38,38,0.3);color:#fecaca;"
      }
      role="alert"
      {@rest}
    >
      <div class="flex items-start gap-3">
        <p class="flex-1">{@msg}</p>
        <button
          type="button"
          style="color:var(--color-text-muted);"
          phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> JS.hide(to: "#flash-#{@kind}")}
          aria-label="close"
        >
          &times;
        </button>
      </div>
    </div>
    """
  end
end
