defmodule LurusWwwWeb.FooterComponents do
  use Phoenix.Component

  alias LurusWww.Data.Products

  def footer(assigns) do
    footer_products = Products.footer_products()
    icp = Application.get_env(:lurus_www, :icp_number, "鲁ICP备2026000242号")

    assigns =
      assigns
      |> assign(:explorers, footer_products.explorers)
      |> assign(:entrepreneurs, footer_products.entrepreneurs)
      |> assign(:builders, footer_products.builders)
      |> assign(:icp, icp)
      |> assign(:year, Date.utc_today().year)

    ~H"""
    <footer style="background-color:var(--color-surface-raised); border-top:1px solid var(--color-surface-border);">
      <div class="max-w-7xl mx-auto px-6 sm:px-8 lg:px-12">
        <%!-- Main grid --%>
        <div style="display:grid; grid-template-columns:2fr 1fr 1fr 1fr; gap:48px; padding:64px 0;" class="footer-grid">
          <%!-- Brand --%>
          <div style="display:flex; flex-direction:column; gap:16px;" class="footer-brand-col">
            <div style="display:flex; align-items:center; gap:10px;">
              <div style="width:36px; height:36px; border-radius:9px; background-color:var(--color-ochre); display:flex; align-items:center; justify-content:center; color:#0D0B09; font-weight:800; font-size:1.125rem;">L</div>
              <span style="font-size:1.25rem; font-weight:700; color:var(--color-text-primary); letter-spacing:-0.02em;">Lurus</span>
            </div>
            <p style="font-size:0.875rem; color:var(--color-text-muted); line-height:1.65; max-width:280px;">
              AI 基础设施生态 — 从个人桌面到企业平台，为每一种可能提供底座。
            </p>
            <div style="display:inline-flex; align-items:center; gap:7px; font-size:0.75rem; color:var(--color-text-muted);">
              <span style="width:6px; height:6px; border-radius:50%; background-color:#4ade80; flex-shrink:0;"></span>
              服务稳定运行中
            </div>
          </div>

          <%!-- Explorers --%>
          <div>
            <h3 class="footer-col-heading" style="font-size:0.7rem; font-weight:600; text-transform:uppercase; letter-spacing:0.12em; color:var(--color-text-secondary); margin-bottom:14px;">探索者</h3>
            <ul style="list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:10px;">
              <li :for={item <- @explorers}>
                <a href={item.href} target={if String.starts_with?(item.href, "http"), do: "_blank"} rel={if String.starts_with?(item.href, "http"), do: "noopener noreferrer"} style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;"><%= item.name %></a>
              </li>
            </ul>
          </div>

          <%!-- Entrepreneurs + Builders --%>
          <div>
            <h3 style="font-size:0.7rem; font-weight:600; text-transform:uppercase; letter-spacing:0.12em; color:var(--color-text-secondary); margin-bottom:14px;">创业者</h3>
            <ul style="list-style:none; padding:0; margin:0 0 24px; display:flex; flex-direction:column; gap:10px;">
              <li :for={item <- @entrepreneurs}>
                <a href={item.href} target={if String.starts_with?(item.href, "http"), do: "_blank"} rel={if String.starts_with?(item.href, "http"), do: "noopener noreferrer"} style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;"><%= item.name %></a>
              </li>
            </ul>
            <h3 style="font-size:0.7rem; font-weight:600; text-transform:uppercase; letter-spacing:0.12em; color:var(--color-text-secondary); margin-bottom:14px;">构建者</h3>
            <ul style="list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:10px;">
              <li :for={item <- @builders}>
                <a href={item.href} target={if String.starts_with?(item.href, "http"), do: "_blank"} rel={if String.starts_with?(item.href, "http"), do: "noopener noreferrer"} style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;"><%= item.name %></a>
              </li>
            </ul>
          </div>

          <%!-- Resources + Company --%>
          <div>
            <h3 style="font-size:0.7rem; font-weight:600; text-transform:uppercase; letter-spacing:0.12em; color:var(--color-text-secondary); margin-bottom:14px;">资源</h3>
            <ul style="list-style:none; padding:0; margin:0 0 24px; display:flex; flex-direction:column; gap:10px;">
              <li><a href="https://docs.lurus.cn" target="_blank" rel="noopener noreferrer" style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;">API 文档</a></li>
              <li><a href="https://docs.lurus.cn/guide/quickstart" target="_blank" rel="noopener noreferrer" style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;">快速入门</a></li>
              <li><a href="/pricing" style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;">定价方案</a></li>
              <li><a href="/download" style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;">下载中心</a></li>
            </ul>
            <h3 style="font-size:0.7rem; font-weight:600; text-transform:uppercase; letter-spacing:0.12em; color:var(--color-text-secondary); margin-bottom:14px;">公司</h3>
            <ul style="list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:10px;">
              <li><a href="/about" style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;">关于我们</a></li>
              <li><a href="mailto:support@lurus.cn" style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;">联系我们</a></li>
              <li><a href="/terms" style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;">服务条款</a></li>
              <li><a href="/privacy" style="font-size:0.875rem; color:var(--color-text-muted); text-decoration:none;">隐私政策</a></li>
            </ul>
          </div>
        </div>

        <%!-- Bottom bar --%>
        <div style="border-top:1px solid var(--color-surface-border); padding:24px 0; display:flex; flex-wrap:wrap; align-items:center; gap:16px; font-size:0.8rem; color:var(--color-text-muted);">
          <span>&copy; <%= @year %> Lurus Technology. All rights reserved.</span>
          <a href="https://beian.miit.gov.cn/" target="_blank" rel="noopener noreferrer" style="color:var(--color-text-muted); text-decoration:none;"><%= @icp %></a>
          <a href="https://www.beian.gov.cn/portal/registerSystemInfo?recordcode=37060002001239" target="_blank" rel="noopener noreferrer" style="color:var(--color-text-muted); text-decoration:none; display:inline-flex; align-items:center; gap:4px;">
            <svg style="width:12px; height:12px; flex-shrink:0;" viewBox="0 0 24 24" fill="none" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
            鲁公网安备37060002001239号
          </a>
        </div>
      </div>
    </footer>
    """
  end
end
