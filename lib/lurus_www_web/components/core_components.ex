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
      class={[
        "fixed top-4 right-4 z-[100] max-w-sm rounded-lg px-4 py-3 text-sm shadow-lg",
        @kind == :info && "bg-surface-overlay border border-ochre/30 text-text-primary",
        @kind == :error && "bg-red-900/80 border border-red-600/30 text-red-100"
      ]}
      role="alert"
      {@rest}
    >
      <div class="flex items-start gap-3">
        <p class="flex-1"><%= @msg %></p>
        <button
          type="button"
          class="text-text-muted hover:text-text-primary"
          phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> JS.hide(to: "#flash-#{@kind}")}
          aria-label="close"
        >
          &times;
        </button>
      </div>
    </div>
    """
  end

  @doc "Primary CTA button"
  attr :href, :string, default: nil
  attr :external, :boolean, default: false
  attr :size, :string, default: "md"
  attr :rest, :global
  slot :inner_block, required: true

  def btn_primary(assigns) do
    ~H"""
    <%= if @href do %>
      <a
        href={@href}
        class={["btn-primary", size_class(:primary, @size)]}
        target={if @external, do: "_blank"}
        rel={if @external, do: "noopener noreferrer"}
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </a>
    <% else %>
      <button class={["btn-primary", size_class(:primary, @size)]} {@rest}>
        <%= render_slot(@inner_block) %>
      </button>
    <% end %>
    """
  end

  @doc "Outline button"
  attr :href, :string, default: nil
  attr :external, :boolean, default: false
  attr :size, :string, default: "md"
  attr :disabled, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def btn_outline(assigns) do
    ~H"""
    <%= if @href do %>
      <a
        href={@href}
        class={["btn-outline", size_class(:outline, @size)]}
        target={if @external, do: "_blank"}
        rel={if @external, do: "noopener noreferrer"}
        {@rest}
      >
        <%= render_slot(@inner_block) %>
      </a>
    <% else %>
      <button class={["btn-outline", size_class(:outline, @size)]} {@rest}>
        <%= render_slot(@inner_block) %>
      </button>
    <% end %>
    """
  end

  @doc "Section container"
  attr :id, :string, default: nil
  attr :class, :string, default: ""
  attr :raised, :boolean, default: false
  slot :inner_block, required: true

  def section(assigns) do
    ~H"""
    <section
      id={@id}
      class={[
        "py-20 md:py-28 px-6 sm:px-8 lg:px-12",
        if(@raised, do: "section-dark-raised", else: "section-dark"),
        @class
      ]}
    >
      <div class="max-w-6xl mx-auto">
        <%= render_slot(@inner_block) %>
      </div>
    </section>
    """
  end

  @doc "SVG icon from path data"
  attr :path, :string, required: true
  attr :class, :string, default: "w-5 h-5"

  def icon(assigns) do
    ~H"""
    <svg class={@class} fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d={@path} />
    </svg>
    """
  end

  @doc "Code block display"
  attr :code, :string, required: true
  attr :language, :string, default: "bash"
  attr :label, :string, default: nil

  def code_block(assigns) do
    ~H"""
    <div class="code-block p-5" role="img" aria-label={@label || "code example"}>
      <pre class="whitespace-pre-wrap"><code><%= @code %></code></pre>
    </div>
    """
  end

  @doc "Neon badge pill"
  attr :color, :string, default: "var(--color-ochre)"
  slot :inner_block, required: true

  def neon_badge(assigns) do
    ~H"""
    <span class="neon-badge" style={"color: #{@color}"}>
      <span class="neon-dot"></span>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  defp size_class(:primary, "sm"), do: "btn-primary--sm"
  defp size_class(:primary, "lg"), do: "btn-primary--lg"
  defp size_class(:outline, "sm"), do: "btn-outline--sm"
  defp size_class(:outline, "lg"), do: "btn-outline--lg"
  defp size_class(_, _), do: nil
end
