defmodule LurusWwwWeb.FooterComponents do
  use Phoenix.Component

  def footer(assigns) do
    assigns = assign(assigns, :year, Date.utc_today().year)

    ~H"""
    <footer class="game-footer">
      <div class="footer-inner">
        <div class="footer-left">
          <span class="footer-brand">WebGame</span>
          <span class="footer-copy">&copy; {@year} Lurus Technology</span>
        </div>
        <div class="footer-links">
          <a href="/terms" class="footer-link">Terms</a>
          <a href="/privacy" class="footer-link">Privacy</a>
          <a href="mailto:support@lurus.cn" class="footer-link">Contact</a>
        </div>
      </div>
    </footer>
    """
  end
end
