defmodule LurusWwwWeb.NavComponents do
  use Phoenix.Component

  alias LurusWww.Data.Products
  alias LurusWww.Data.Navigation

  attr :current_path, :string, default: "/"
  attr :current_user, :map, default: nil

  def topbar(assigns) do
    nav_products = Products.nav_products()
    icon_paths = Navigation.icon_paths()

    assigns =
      assigns
      |> assign(:consumer, nav_products.consumer)
      |> assign(:infra, nav_products.infra)
      |> assign(:dev, nav_products.dev)
      |> assign(:icons, icon_paths)

    ~H"""
    <header
      class="app-topbar"
      id="topbar"
      phx-hook="TopBarScroll"
      aria-label="Main navigation"
      style="grid-area:topbar; height:64px; position:sticky; top:0; z-index:50; background-color:rgba(13,11,9,0.85); border-bottom:1px solid transparent; backdrop-filter:blur(12px); -webkit-backdrop-filter:blur(12px); transition:border-color 0.3s ease, background-color 0.3s ease;"
    >
      <div style="display:flex; align-items:center; height:100%; max-width:1280px; margin:0 auto; padding:0 24px; gap:8px;">
        <%!-- Logo --%>
        <a href="/" class="topbar-logo" style="display:flex; align-items:center; gap:10px; text-decoration:none; flex-shrink:0;">
          <div style="width:32px; height:32px; border-radius:7px; background-color:var(--color-ochre); display:flex; align-items:center; justify-content:center; font-weight:700; font-size:16px; color:#0D0B09;">L</div>
          <span style="font-size:18px; font-weight:700; color:var(--color-text-primary); letter-spacing:-0.02em;">Lurus</span>
        </a>

        <%!-- Desktop nav --%>
        <nav class="hidden md:flex items-center gap-0.5 mx-auto flex-1 justify-center" aria-label="Primary">
          <%!-- Products dropdown --%>
          <div class="relative" id="products-dropdown" phx-hook="DropdownMenu">
            <button
              class="nav-link inline-flex items-center gap-1 px-3.5 py-1.5 text-sm font-medium rounded-lg"
              style="color:var(--color-text-secondary); background:transparent; border:none; cursor:pointer;"
              aria-haspopup="true"
              data-dropdown-trigger
            >
              产品
              <svg class="w-3.5 h-3.5 transition-transform duration-200" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>

            <div
              class="mega-menu hidden"
              data-dropdown-panel
              role="dialog"
              aria-label="Products menu"
              style="position:absolute; top:calc(100% + 10px); left:50%; transform:translateX(-50%); width:640px; background-color:var(--color-surface-overlay); border:1px solid var(--color-surface-border); border-radius:14px; box-shadow:0 20px 60px rgba(0,0,0,0.6); overflow:hidden; z-index:60;"
            >
              <div style="display:grid; grid-template-columns:1fr 1px 1fr 1px 1fr; gap:0; padding:16px;">
                <%!-- Consumer --%>
                <div>
                  <p style="font-size:11px; font-weight:600; letter-spacing:0.08em; text-transform:uppercase; color:var(--color-text-muted); padding:4px 8px 8px;">个人工具</p>
                  <.mega_item :for={item <- @consumer} item={item} icons={@icons} />
                  <a href="/for-explorers" style="display:block; margin-top:8px; padding:6px 8px; font-size:12px; font-weight:500; color:var(--color-ochre); text-decoration:none;">个人版全部方案 →</a>
                </div>
                <div style="background-color:var(--color-surface-border); margin:0 8px;" aria-hidden="true"></div>
                <%!-- Infra --%>
                <div>
                  <p style="font-size:11px; font-weight:600; letter-spacing:0.08em; text-transform:uppercase; color:var(--color-text-muted); padding:4px 8px 8px;">AI 基础设施</p>
                  <.mega_item :for={item <- @infra} item={item} icons={@icons} />
                  <a href="/for-entrepreneurs" style="display:block; margin-top:8px; padding:6px 8px; font-size:12px; font-weight:500; color:var(--color-ochre); text-decoration:none;">企业版方案 →</a>
                </div>
                <div style="background-color:var(--color-surface-border); margin:0 8px;" aria-hidden="true"></div>
                <%!-- Dev --%>
                <div>
                  <p style="font-size:11px; font-weight:600; letter-spacing:0.08em; text-transform:uppercase; color:var(--color-text-muted); padding:4px 8px 8px;">开发者平台</p>
                  <.mega_item :for={item <- @dev} item={item} icons={@icons} />
                  <a href="/for-builders" style="display:block; margin-top:8px; padding:6px 8px; font-size:12px; font-weight:500; color:var(--color-ochre); text-decoration:none;">开发者集成方案 →</a>
                </div>
              </div>
            </div>
          </div>

          <a href="/pricing" class="nav-link" style="display:inline-flex; align-items:center; padding:7px 14px; font-size:14px; font-weight:500; color:var(--color-text-secondary); border-radius:7px; text-decoration:none;">定价</a>
          <a href="https://docs.lurus.cn" target="_blank" rel="noopener noreferrer" class="nav-link" style="display:inline-flex; align-items:center; padding:7px 14px; font-size:14px; font-weight:500; color:var(--color-text-secondary); border-radius:7px; text-decoration:none;">文档</a>
          <a href="/about" class="nav-link" style="display:inline-flex; align-items:center; padding:7px 14px; font-size:14px; font-weight:500; color:var(--color-text-secondary); border-radius:7px; text-decoration:none;">关于</a>
        </nav>

        <%!-- Auth area --%>
        <div class="hidden md:flex items-center gap-1 flex-shrink-0">
          <a href="https://mail.lurus.cn" target="_blank" rel="noopener noreferrer" aria-label="Lurus Mail" title="Lurus Mail"
            style="display:flex; align-items:center; justify-content:center; width:32px; height:32px; border-radius:7px; color:var(--color-text-muted); text-decoration:none;">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
          </a>
          <%= if @current_user do %>
            <div style="display:flex; align-items:center; gap:8px; padding:4px 10px 4px 4px; border-radius:20px; background-color:rgba(255,255,255,0.06); border:1px solid var(--color-surface-border);">
              <div style="width:24px; height:24px; border-radius:50%; background-color:var(--color-ochre); display:flex; align-items:center; justify-content:center; font-size:11px; font-weight:700; color:#0D0B09;">
                <%= String.first(@current_user.name || "U") |> String.upcase() %>
              </div>
              <span style="font-size:13px; font-weight:500; color:var(--color-text-primary);"><%= @current_user.name %></span>
            </div>
            <a href="/auth/logout" style="display:inline-flex; padding:7px 14px; font-size:14px; color:var(--color-text-muted); text-decoration:none;">退出</a>
          <% else %>
            <a href="/auth/login" style="display:inline-flex; padding:7px 14px; font-size:14px; font-weight:500; color:var(--color-text-secondary); text-decoration:none;">登录</a>
            <a href="/auth/login?prompt=create" style="display:inline-flex; align-items:center; gap:6px; padding:7px 16px; font-size:14px; font-weight:600; background-color:var(--color-ochre); color:#0D0B09; border-radius:8px; text-decoration:none;">
              免费开始 <span aria-hidden="true">→</span>
            </a>
          <% end %>
        </div>

        <%!-- Mobile hamburger --%>
        <button
          class="flex md:hidden items-center justify-center w-9 h-9 rounded-lg ml-auto"
          style="color:var(--color-text-secondary); background:transparent; border:none; cursor:pointer;"
          phx-click={Phoenix.LiveView.JS.toggle(to: "#mobile-menu")}
          aria-label="Toggle navigation"
        >
          <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>

      <%!-- Mobile menu --%>
      <div
        id="mobile-menu"
        class="hidden"
        role="dialog"
        aria-modal="true"
        aria-label="Navigation menu"
        style="position:fixed; inset:64px 0 0; background-color:var(--color-surface-overlay); border-top:1px solid var(--color-surface-border); overflow-y:auto; z-index:49;"
      >
        <div style="padding:16px; display:flex; flex-direction:column; gap:2px;">
          <p style="font-size:11px; font-weight:600; letter-spacing:0.08em; text-transform:uppercase; color:var(--color-text-muted); padding:8px 12px 4px;">个人工具</p>
          <.mobile_nav_item :for={item <- @consumer} item={item} icons={@icons} />
          <div style="height:1px; background-color:var(--color-surface-border); margin:6px 0;"></div>
          <p style="font-size:11px; font-weight:600; letter-spacing:0.08em; text-transform:uppercase; color:var(--color-text-muted); padding:8px 12px 4px;">AI 基础设施</p>
          <.mobile_nav_item :for={item <- @infra} item={item} icons={@icons} />
          <div style="height:1px; background-color:var(--color-surface-border); margin:6px 0;"></div>
          <p style="font-size:11px; font-weight:600; letter-spacing:0.08em; text-transform:uppercase; color:var(--color-text-muted); padding:8px 12px 4px;">开发者平台</p>
          <.mobile_nav_item :for={item <- @dev} item={item} icons={@icons} />
          <div style="height:1px; background-color:var(--color-surface-border); margin:6px 0;"></div>
          <a href="/pricing" style="display:flex; align-items:center; padding:11px 12px; font-size:14px; font-weight:500; color:var(--color-text-secondary); border-radius:8px; text-decoration:none;">定价</a>
          <a href="https://docs.lurus.cn" target="_blank" rel="noopener noreferrer" style="display:flex; align-items:center; padding:11px 12px; font-size:14px; font-weight:500; color:var(--color-text-secondary); border-radius:8px; text-decoration:none;">文档</a>
          <a href="/about" style="display:flex; align-items:center; padding:11px 12px; font-size:14px; font-weight:500; color:var(--color-text-secondary); border-radius:8px; text-decoration:none;">关于</a>
          <div style="height:1px; background-color:var(--color-surface-border); margin:6px 0;"></div>
          <a href="/auth/login" style="display:flex; align-items:center; padding:11px 12px; font-size:14px; font-weight:500; color:var(--color-text-secondary); border-radius:8px; text-decoration:none;">登录</a>
          <a href="/auth/login?prompt=create" style="margin:8px 0; padding:12px; font-size:15px; font-weight:600; background-color:var(--color-ochre); color:#0D0B09; border-radius:10px; text-align:center; text-decoration:none; display:block;">免费开始</a>
        </div>
      </div>
    </header>
    """
  end

  defp mega_item(assigns) do
    ~H"""
    <a
      href={@item.href}
      target={if @item.external, do: "_blank"}
      rel={if @item.external, do: "noopener noreferrer"}
      style="display:flex; align-items:flex-start; gap:10px; padding:8px; border-radius:8px; text-decoration:none; cursor:pointer;"
      class="hover:bg-white/5"
    >
      <svg style="width:18px; height:18px; color:var(--color-ochre); flex-shrink:0; margin-top:1px;" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d={Map.get(@icons, @item.icon, "")} />
      </svg>
      <span>
        <span style="display:block; font-size:13px; font-weight:500; color:var(--color-text-primary); line-height:1.3;"><%= @item.name %></span>
        <span style="display:block; font-size:11px; color:var(--color-text-muted); margin-top:1px; line-height:1.4;"><%= @item.desc %></span>
      </span>
    </a>
    """
  end

  defp mobile_nav_item(assigns) do
    ~H"""
    <a
      href={@item.href}
      target={if @item.external, do: "_blank"}
      rel={if @item.external, do: "noopener noreferrer"}
      style="display:flex; align-items:center; gap:10px; padding:11px 12px; font-size:14px; font-weight:500; color:var(--color-text-secondary); border-radius:8px; text-decoration:none;"
    >
      <svg style="width:16px; height:16px; color:var(--color-ochre); flex-shrink:0;" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d={Map.get(@icons, @item.icon, "")} />
      </svg>
      <span><%= @item.name %></span>
    </a>
    """
  end
end
