defmodule LurusWwwWeb.Live.CreatorLive do
  use LurusWwwWeb, :live_view

  @templates [
    %{id: "custom", label: "Custom", icon: "M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"},
    %{id: "snake", label: "Snake", icon: "M13 10V3L4 14h7v7l9-11h-7z"},
    %{id: "pong", label: "Pong", icon: "M18 3a3 3 0 00-3 3v12a3 3 0 003 3 3 3 0 003-3V6a3 3 0 00-3-3zM6 3a3 3 0 00-3 3v12a3 3 0 003 3 3 3 0 003-3V6a3 3 0 00-3-3z"},
    %{id: "breakout", label: "Breakout", icon: "M4 6h16M4 10h16M4 14h16M4 18h16"},
    %{id: "platformer", label: "Platformer", icon: "M5 12h14M12 5l7 7-7 7"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Create - WebGame",
        prompt: "",
        selected_template: "custom",
        generating: false,
        templates: @templates
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("select_template", %{"id" => id}, socket) do
    {:noreply, assign(socket, selected_template: id)}
  end

  def handle_event("update_prompt", %{"prompt" => prompt}, socket) do
    {:noreply, assign(socket, prompt: prompt)}
  end

  def handle_event("generate", _params, socket) do
    {:noreply, assign(socket, generating: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="creator-page">
      <div class="creator-container">
        <div class="creator-split">
          <%!-- Left: Input Panel --%>
          <div class="creator-left">
            <h1 class="creator-title">Game Creator</h1>
            <p class="creator-subtitle">
              Describe your game and let AI build it for you.
            </p>

            <%!-- Template Chips --%>
            <div class="template-row">
              <%= for t <- @templates do %>
                <button
                  phx-click="select_template"
                  phx-value-id={t.id}
                  class={"template-chip #{if @selected_template == t.id, do: "active"}"}
                >
                  {t.label}
                </button>
              <% end %>
            </div>

            <%!-- Prompt Input --%>
            <form phx-submit="generate" class="creator-form">
              <textarea
                name="prompt"
                value={@prompt}
                phx-change="update_prompt"
                class="creator-textarea"
                placeholder={"Describe your game idea...\n\nExample: A 2-player pong game where the ball speeds up every 10 hits. Neon color scheme with particle effects."}
                rows="8"
              ></textarea>

              <button type="submit" class={"btn-accent btn-accent--lg w-full #{if @generating, do: "generating"}"} disabled={@generating}>
                <%= if @generating do %>
                  <span class="spinner"></span> Generating...
                <% else %>
                  Generate with AI
                <% end %>
              </button>
            </form>

            <div class="creator-features">
              <div class="creator-feature">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00F0FF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
                <span>AI-powered code generation</span>
              </div>
              <div class="creator-feature">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#00FF87" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                <span>Sandboxed execution</span>
              </div>
              <div class="creator-feature">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FFB800" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                <span>Publish & monetize</span>
              </div>
            </div>
          </div>

          <%!-- Right: Preview Panel --%>
          <div class="creator-right">
            <div class="preview-panel">
              <div class="preview-header">
                <span class="preview-dot"></span>
                Preview
              </div>
              <div class="preview-body">
                <%= if @generating do %>
                  <div class="preview-loading">
                    <div class="spinner-lg"></div>
                    <p>AI is generating your game...</p>
                  </div>
                <% else %>
                  <div class="preview-empty">
                    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#252535" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                    <p>Your game preview will appear here</p>
                    <p class="text-xs text-muted">Describe a game and click Generate</p>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
