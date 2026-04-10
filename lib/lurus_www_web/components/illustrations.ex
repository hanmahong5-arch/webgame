defmodule LurusWwwWeb.Illustrations do
  @moduledoc """
  SVG illustration components for the homepage product sections.
  Each renders an animated diagram that activates on scroll via DiagramReveal hook.
  """
  use Phoenix.Component

  # -- API Flow Diagram --
  # 5 LLM model nodes → Lurus API Gateway → Your App

  @api_models [
    %{label: "Claude", y: 28},
    %{label: "GPT-4o", y: 68},
    %{label: "Gemini", y: 108},
    %{label: "DeepSeek", y: 148},
    %{label: "Qwen", y: 188}
  ]

  def api_flow(assigns) do
    assigns = assign(assigns, :models, @api_models)

    ~H"""
    <svg
      viewBox="0 0 520 220" fill="none" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Multiple LLM providers connect through Lurus API gateway to your app"
      class="w-full h-full diagram-svg"
      id="api-flow-svg" phx-hook="DiagramReveal"
    >
      <%!-- Background glow --%>
      <ellipse cx="265" cy="110" rx="60" ry="50" fill="#4A9EFF" opacity="0.06" class="dia-reveal" />

      <%!-- Left: LLM model nodes --%>
      <%= for {model, i} <- Enum.with_index(@models) do %>
        <rect
          x="12" y={model.y - 13} width="80" height="26" rx="6"
          fill="#1C1916" stroke="#4A9EFF" stroke-width="1.2" stroke-opacity="0.5"
          class="dia-draw" style={"animation-delay:#{i * 80}ms"}
        />
        <text
          x="52" y={model.y + 5} text-anchor="middle"
          font-size="10" font-family="ui-monospace,monospace" fill="#A89B8B"
        ><%= model.label %></text>
        <line
          x1="94" y1={model.y} x2="220" y2="110"
          stroke="#4A9EFF" stroke-width="1" stroke-dasharray="4 3" stroke-opacity="0.4"
          class="dia-draw-line" style={"animation-delay:#{200 + i * 80}ms"}
        />
        <circle r="2.5" fill="#4A9EFF" opacity="0.85" class="dia-reveal">
          <animateMotion dur={"#{2.2 + i * 0.18}s"} repeatCount="indefinite" path={"M94,#{model.y} L220,110"} />
        </circle>
      <% end %>

      <%!-- Center: API Gateway --%>
      <rect x="205" y="76" width="120" height="68" rx="12"
        fill="#141210" stroke="#4A9EFF" stroke-width="2"
        class="dia-draw" style="animation-delay:550ms" />
      <rect x="209" y="80" width="112" height="60" rx="9"
        fill="none" stroke="#4A9EFF" stroke-width="0.5" stroke-opacity="0.3" class="dia-reveal" />
      <text x="265" y="108" text-anchor="middle" font-size="12" font-weight="600" font-family="ui-monospace,monospace" fill="#F5F0E8">Lurus API</text>
      <text x="265" y="124" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#4A9EFF" fill-opacity="0.85">Gateway</text>
      <circle cx="265" cy="96" r="3" fill="#4A9EFF" opacity="0.9" class="dia-reveal pulse-gw" />

      <%!-- Right arrow --%>
      <line x1="326" y1="110" x2="408" y2="110"
        stroke="#4A9EFF" stroke-width="1.5" stroke-dasharray="5 3" stroke-opacity="0.6"
        class="dia-draw-line" style="animation-delay:750ms" />
      <polygon points="408,104 420,110 408,116" fill="#4A9EFF" opacity="0.7" class="dia-reveal" />
      <circle r="3" fill="#4A9EFF" opacity="0.9" class="dia-reveal">
        <animateMotion dur="1.8s" repeatCount="indefinite" path="M326,110 L408,110" />
      </circle>

      <%!-- Right: Your App --%>
      <rect x="418" y="82" width="86" height="56" rx="10"
        fill="#141210" stroke="#D4A827" stroke-width="1.8"
        class="dia-draw" style="animation-delay:900ms" />
      <text x="461" y="110" text-anchor="middle" font-size="11" font-weight="600" font-family="ui-monospace,monospace" fill="#F5F0E8">Your</text>
      <text x="461" y="125" text-anchor="middle" font-size="11" font-weight="600" font-family="ui-monospace,monospace" fill="#D4A827">App</text>
    </svg>
    """
  end

  # -- Kova Diagram --
  # WAL log stack + Agent hexagon + Plan/Execute/Review cycle

  @wal_entries [
    %{label: "WAL[003] Execute", y: 48},
    %{label: "WAL[002] Plan", y: 80},
    %{label: "WAL[001] Init", y: 112},
    %{label: "WAL[000] Start", y: 144}
  ]

  @kova_satellites [
    %{label: "Plan", color: "#E0C8FF", angle_deg: -90},
    %{label: "Execute", color: "#B08EFF", angle_deg: 30},
    %{label: "Review", color: "#C4A8FF", angle_deg: 150}
  ]

  @hex_cx 265
  @hex_cy 120
  @hex_r 44
  @sat_rx 104
  @sat_ry 56

  defp hex_points(cx, cy, r) do
    Enum.map(0..5, fn i ->
      a = :math.pi() / 3 * i - :math.pi() / 6
      x = Float.round(cx + r * :math.cos(a), 1)
      y = Float.round(cy + r * :math.sin(a), 1)
      "#{x},#{y}"
    end)
    |> Enum.join(" ")
  end

  defp sat_pos(angle_deg, cx, cy, rx, ry) do
    a = angle_deg * :math.pi() / 180
    {Float.round(cx + rx * :math.cos(a), 1), Float.round(cy + ry * :math.sin(a), 1)}
  end

  def kova(assigns) do
    hex_pts = hex_points(@hex_cx, @hex_cy, @hex_r)
    hex_pts_inner = hex_points(@hex_cx, @hex_cy, @hex_r - 6)
    orbit_path = "M 355,120 A 90,50 0 1,1 354.9999,120"

    satellites_with_pos =
      Enum.with_index(@kova_satellites)
      |> Enum.map(fn {sat, i} ->
        {sx, sy} = sat_pos(sat.angle_deg, @hex_cx, @hex_cy, @sat_rx, @sat_ry)
        Map.merge(sat, %{x: sx, y: sy, idx: i})
      end)

    assigns =
      assigns
      |> assign(:wal_entries, @wal_entries)
      |> assign(:hex_pts, hex_pts)
      |> assign(:hex_pts_inner, hex_pts_inner)
      |> assign(:orbit_path, orbit_path)
      |> assign(:satellites, satellites_with_pos)
      |> assign(:hex_cx, @hex_cx)
      |> assign(:hex_cy, @hex_cy)
      |> assign(:hex_r, @hex_r)

    ~H"""
    <svg
      viewBox="0 0 520 240" fill="none" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Kova: WAL-backed persistent Agent Loop"
      class="w-full h-full diagram-svg"
      id="kova-svg" phx-hook="DiagramReveal"
    >
      <ellipse cx={@hex_cx} cy={@hex_cy} rx="70" ry="60" fill="#B08EFF" opacity="0.07" class="dia-reveal" />

      <%!-- WAL log stack --%>
      <%= for {entry, i} <- Enum.with_index(@wal_entries) do %>
        <rect x="12" y={entry.y - 12} width="136" height="24" rx="5"
          fill="#1C1916" stroke="#B08EFF" stroke-width="1" stroke-opacity="0.45"
          class="dia-draw" style={"animation-delay:#{i * 100}ms"} />
        <text x="20" y={entry.y + 4} font-size="9.5" font-family="ui-monospace,monospace" fill="#A89B8B"><%= entry.label %></text>
        <line x1="150" y1={entry.y} x2={@hex_cx - @hex_r - 2} y2={@hex_cy}
          stroke="#B08EFF" stroke-width="0.8" stroke-dasharray="3 3" stroke-opacity="0.35"
          class="dia-draw-line" style={"animation-delay:#{350 + i * 80}ms"} />
        <circle r="2.2" fill="#B08EFF" opacity="0.8" class="dia-reveal">
          <animateMotion dur={"#{2.8 + i * 0.3}s"} repeatCount="indefinite" begin={"#{i * 0.4}s"}
            path={"M150,#{entry.y} L#{@hex_cx - @hex_r - 2},#{@hex_cy}"} />
        </circle>
      <% end %>

      <%!-- Orbit ellipse --%>
      <ellipse cx={@hex_cx} cy={@hex_cy} rx="90" ry="50"
        fill="none" stroke="#B08EFF" stroke-width="0.6" stroke-dasharray="4 4" stroke-opacity="0.2" class="dia-reveal" />

      <%!-- Orbit particles --%>
      <%= for {_sat, i} <- Enum.with_index(@satellites) do %>
        <circle r="3.5" fill="#B08EFF" opacity="0.85" class="dia-reveal">
          <animateMotion dur="8s" repeatCount="indefinite" begin={"#{Float.round(i * 8 / 3, 2)}s"} path={@orbit_path} />
        </circle>
      <% end %>

      <%!-- Satellite label nodes --%>
      <%= for sat <- @satellites do %>
        <rect x={sat.x - 26} y={sat.y - 12} width="52" height="24" rx="12"
          fill="#1C1916" stroke={sat.color} stroke-width="1.2" class="dia-reveal"
          style={"transition:opacity 0.4s #{0.7 + sat.idx * 0.15}s"} />
        <text x={sat.x} y={sat.y + 4} text-anchor="middle"
          font-size="10" font-family="ui-monospace,monospace" fill={sat.color} class="dia-reveal"><%= sat.label %></text>
      <% end %>

      <%!-- Center hexagon --%>
      <polygon points={@hex_pts} fill="#141210" stroke="#B08EFF" stroke-width="2"
        class="dia-draw" style="animation-delay:500ms" />
      <polygon points={@hex_pts_inner} fill="none" stroke="#B08EFF" stroke-width="0.5" stroke-opacity="0.3" class="dia-reveal" />
      <text x={@hex_cx} y={@hex_cy - 6} text-anchor="middle" font-size="11" font-weight="700" font-family="ui-monospace,monospace" fill="#F5F0E8">Agent</text>
      <text x={@hex_cx} y={@hex_cy + 10} text-anchor="middle" font-size="11" font-weight="700" font-family="ui-monospace,monospace" fill="#B08EFF">Loop</text>
    </svg>
    """
  end

  # -- Lucrum Chart Diagram --
  # Candlestick chart with MA line and AI buy signal

  @candles [
    %{x: 60, open: 150, close: 130, high: 125, low: 158, green: false},
    %{x: 100, open: 132, close: 112, high: 108, low: 140, green: false},
    %{x: 140, open: 114, close: 130, high: 106, low: 136, green: true},
    %{x: 180, open: 128, close: 108, high: 104, low: 134, green: false},
    %{x: 220, open: 110, close: 125, high: 102, low: 128, green: true},
    %{x: 260, open: 123, close: 108, high: 102, low: 130, green: false},
    %{x: 300, open: 110, close: 92, high: 88, low: 116, green: false},
    %{x: 340, open: 94, close: 110, high: 86, low: 116, green: true},
    %{x: 380, open: 108, close: 88, high: 84, low: 114, green: false},
    %{x: 420, open: 90, close: 72, high: 68, low: 96, green: false}
  ]

  @ma_points "60,145 100,138 140,128 180,122 220,118 260,115 300,108 340,100 380,95 420,88"

  def lucrum_chart(assigns) do
    assigns =
      assigns
      |> assign(:candles, @candles)
      |> assign(:ma_points, @ma_points)

    ~H"""
    <svg
      viewBox="0 0 520 240" fill="none" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Lucrum AI quantitative trading: candlestick chart with AI buy signal"
      class="w-full h-full diagram-svg"
      id="lucrum-chart-svg" phx-hook="DiagramReveal"
    >
      <rect x="30" y="20" width="450" height="185" rx="8" fill="#0D0B09" stroke="#2A2520" stroke-width="1" />
      <%= for y <- [60, 100, 140, 180] do %>
        <line x1="30" y1={y} x2="480" y2={y} stroke="#2A2520" stroke-width="0.5" />
      <% end %>

      <%!-- MA line --%>
      <polyline points={@ma_points} stroke="#4A9EFF" stroke-width="1.2" stroke-opacity="0.6" fill="none" class="dia-ma-line" />

      <%!-- Candlesticks --%>
      <%= for {candle, i} <- Enum.with_index(@candles) do %>
        <% color = if candle.green, do: "#7AFF89", else: "#FF6B6B" %>
        <% body_y = if candle.green, do: candle.open, else: candle.close %>
        <line x1={candle.x} y1={candle.high} x2={candle.x} y2={candle.low}
          stroke={color} stroke-width="1.5"
          class="dia-draw-line" style={"animation-delay:#{i * 60}ms"} />
        <rect x={candle.x - 10} y={body_y} width="20" height={abs(candle.close - candle.open)}
          fill={color} fill-opacity={if candle.green, do: "0.85", else: "0.7"} rx="2"
          class="dia-fade-in" style={"animation-delay:#{i * 60 + 100}ms"} />
      <% end %>

      <%!-- AI Buy Signal --%>
      <circle cx="340" cy="86" r="8" stroke="#7AFF89" stroke-width="1.5" fill="none" class="dia-reveal dia-ripple-1" />
      <circle cx="340" cy="86" r="16" stroke="#7AFF89" stroke-width="1" fill="none" class="dia-reveal dia-ripple-2" />
      <circle cx="340" cy="86" r="24" stroke="#7AFF89" stroke-width="0.7" fill="none" class="dia-reveal dia-ripple-3" />
      <rect x="324" y="54" width="32" height="16" rx="4" fill="#141210" stroke="#7AFF89" stroke-width="1" class="dia-reveal" />
      <text x="340" y="66" text-anchor="middle" font-size="8.5" font-family="ui-monospace,monospace" fill="#7AFF89" class="dia-reveal">AI 买入</text>

      <%!-- Legend --%>
      <g class="dia-reveal" style="opacity:0.75">
        <line x1="36" y1="208" x2="56" y2="208" stroke="#4A9EFF" stroke-width="1.5" />
        <text x="60" y="212" font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D">MA5</text>
        <rect x="90" y="202" width="8" height="12" rx="1" fill="#7AFF89" fill-opacity="0.8" />
        <text x="102" y="212" font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D">买入</text>
        <rect x="130" y="202" width="8" height="12" rx="1" fill="#FF6B6B" fill-opacity="0.7" />
        <text x="142" y="212" font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D">卖出</text>
      </g>
    </svg>
    """
  end

  # -- MemX Graph Diagram --
  # Central YOU node + 6 memory nodes + timeline

  @mem_nodes [
    %{label: "工作记忆", angle: -90, r: 82},
    %{label: "偏好设置", angle: -30, r: 88},
    %{label: "项目上下文", angle: 30, r: 82},
    %{label: "代码片段", angle: 90, r: 80},
    %{label: "历史对话", angle: 150, r: 88},
    %{label: "知识库", angle: 210, r: 82}
  ]

  @memx_cx 250
  @memx_cy 115
  @timeline_y 210
  @timeline_nodes [80, 160, 240, 320, 400, 480]

  defp node_pos(angle, r, cx, cy) do
    a = angle * :math.pi() / 180
    {Float.round(cx + r * :math.cos(a), 1), Float.round(cy + r * :math.sin(a), 1)}
  end

  def memx_graph(assigns) do
    nodes_with_pos =
      Enum.with_index(@mem_nodes)
      |> Enum.map(fn {node, i} ->
        {nx, ny} = node_pos(node.angle, node.r, @memx_cx, @memx_cy)
        Map.merge(node, %{x: nx, y: ny, idx: i})
      end)

    assigns =
      assigns
      |> assign(:nodes, nodes_with_pos)
      |> assign(:cx, @memx_cx)
      |> assign(:cy, @memx_cy)
      |> assign(:timeline_y, @timeline_y)
      |> assign(:timeline_nodes, Enum.with_index(@timeline_nodes))

    ~H"""
    <svg
      viewBox="0 0 520 240" fill="none" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="MemX: cross-session persistent AI memory graph"
      class="w-full h-full diagram-svg"
      id="memx-graph-svg" phx-hook="DiagramReveal"
    >
      <circle cx={@cx} cy={@cy} r="55" fill="#4AFFCB" opacity="0.06" class="dia-reveal" />

      <%!-- Connectors + particles --%>
      <%= for node <- @nodes do %>
        <line x1={@cx} y1={@cy} x2={node.x} y2={node.y}
          stroke="#4AFFCB" stroke-width="0.9" stroke-dasharray="4 3" stroke-opacity="0.35"
          class="dia-draw-line" style={"animation-delay:#{300 + node.idx * 80}ms"} />
        <circle r="2" fill="#4AFFCB" opacity="0.7" class="dia-reveal">
          <animateMotion dur={"#{3 + node.idx * 0.3}s"} repeatCount="indefinite" begin={"#{node.idx * 0.5}s"}
            path={"M#{node.x},#{node.y} L#{@cx},#{@cy}"} />
        </circle>
      <% end %>

      <%!-- Memory node circles + labels --%>
      <%= for node <- @nodes do %>
        <circle cx={node.x} cy={node.y} r="22"
          fill="#141210" stroke="#4AFFCB" stroke-width="1.2" stroke-opacity="0.6"
          class="dia-reveal dia-pulse-node"
          style={"animation-delay:#{0.5 + node.idx * 0.15}s;transition:opacity 0.4s #{0.4 + node.idx * 0.1}s"} />
        <text x={node.x} y={node.y + 4} text-anchor="middle"
          font-size="8.5" font-family="ui-monospace,monospace" fill="#A89B8B" class="dia-reveal"><%= node.label %></text>
      <% end %>

      <%!-- Center YOU node --%>
      <circle cx={@cx} cy={@cy} r="32" fill="#1C1916" stroke="#4AFFCB" stroke-width="2"
        class="dia-draw" style="animation-delay:100ms" />
      <circle cx={@cx} cy={@cy} r="26" fill="none" stroke="#4AFFCB" stroke-width="0.5" stroke-opacity="0.3" class="dia-reveal" />
      <text x={@cx} y={@cy - 3} text-anchor="middle" font-size="13" font-weight="700" font-family="ui-monospace,monospace" fill="#F5F0E8">YOU</text>
      <text x={@cx} y={@cy + 13} text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#4AFFCB">AI 记忆中心</text>

      <%!-- Timeline --%>
      <line x1="60" y1={@timeline_y} x2="460" y2={@timeline_y} stroke="#2A2520" stroke-width="1.5" />
      <%= for {tx, i} <- @timeline_nodes do %>
        <circle cx={tx} cy={@timeline_y} r="3.5"
          fill="#1C1916" stroke="#4AFFCB" stroke-width="1.2" stroke-opacity="0.5"
          class="dia-reveal dia-pulse-node"
          style={"animation-delay:#{0.9 + i * 0.1}s;transition:opacity 0.3s #{0.8 + i * 0.1}s"} />
        <circle r="1.8" fill="#4AFFCB" opacity="0.6" class="dia-reveal">
          <animateMotion dur={"#{2.5 + i * 0.25}s"} repeatCount="indefinite" begin={"#{i * 0.4}s"}
            path={"M#{tx},#{@timeline_y} L#{@cx},#{@cy + 32}"} />
        </circle>
      <% end %>
      <text x="60" y={@timeline_y + 14} font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D">历史会话</text>
      <text x="420" y={@timeline_y + 14} font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D" text-anchor="end">当前</text>
    </svg>
    """
  end

  # -- Creator Pipeline Diagram --
  # 5 stages: Input → yt-dlp → Whisper → LLM → Publish (fan-out to 3 targets)

  @creator_stages [
    %{label: "输入视频", icon: "▶", x: 52},
    %{label: "yt-dlp", icon: "⬇", x: 152},
    %{label: "Whisper", icon: "🎙", x: 255},
    %{label: "LLM 编辑", icon: "✦", x: 358},
    %{label: "发布", icon: "⇥", x: 458}
  ]

  @pipeline_y 100

  @publish_targets [
    %{label: "YouTube", x: 510, y: 50},
    %{label: "微信视频号", x: 510, y: 100},
    %{label: "抖音", x: 510, y: 150}
  ]

  def creator_pipeline(assigns) do
    stages_indexed = Enum.with_index(@creator_stages)

    assigns =
      assigns
      |> assign(:stages, @creator_stages)
      |> assign(:stages_indexed, stages_indexed)
      |> assign(:pipeline_y, @pipeline_y)
      |> assign(:targets, Enum.with_index(@publish_targets))

    ~H"""
    <svg
      viewBox="0 0 560 200" fill="none" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Creator pipeline: video input to multi-platform publish"
      class="w-full h-full diagram-svg"
      id="creator-pipeline-svg" phx-hook="DiagramReveal"
    >
      <%!-- Connectors between stages --%>
      <%= for i <- 0..3 do %>
        <% s1 = Enum.at(@stages, i) %>
        <% s2 = Enum.at(@stages, i + 1) %>
        <line x1={s1.x + 34} y1={@pipeline_y} x2={s2.x - 34} y2={@pipeline_y}
          stroke="#FFB86C" stroke-width="1.5" stroke-dasharray="5 3" stroke-opacity="0.5"
          class="dia-draw-line" style={"animation-delay:#{200 + i * 150}ms"} />
        <circle r="3" fill="#FFB86C" opacity="0.9" class="dia-reveal">
          <animateMotion dur={"#{1.8 + i * 0.1}s"} repeatCount="indefinite" begin={"#{i * 0.3}s"}
            path={"M#{s1.x + 34},#{@pipeline_y} L#{s2.x - 34},#{@pipeline_y}"} />
        </circle>
      <% end %>

      <%!-- Stage boxes --%>
      <%= for {stage, i} <- @stages_indexed do %>
        <rect x={stage.x - 34} y={@pipeline_y - 28} width="68" height="56" rx="10"
          fill="#141210" stroke="#FFB86C" stroke-width="1.5" stroke-opacity="0.7"
          class="dia-draw" style={"animation-delay:#{i * 120}ms"} />
        <text x={stage.x} y={@pipeline_y - 8} text-anchor="middle" font-size="16" fill="#FFB86C"><%= stage.icon %></text>
        <text x={stage.x} y={@pipeline_y + 14} text-anchor="middle" font-size="9.5" font-family="ui-monospace,monospace" fill="#A89B8B"><%= stage.label %></text>
      <% end %>

      <%!-- Fan-out to publish targets --%>
      <% last_stage = List.last(@stages) %>
      <%= for {target, i} <- @targets do %>
        <line x1={last_stage.x + 34} y1={@pipeline_y} x2={target.x - 44} y2={target.y}
          stroke="#FFB86C" stroke-width="1" stroke-dasharray="4 3" stroke-opacity="0.45"
          class="dia-draw-line" style={"animation-delay:#{750 + i * 100}ms"} />
        <circle r="2.5" fill="#FFB86C" opacity="0.8" class="dia-reveal">
          <animateMotion dur={"#{2 + i * 0.2}s"} repeatCount="indefinite" begin={"#{i * 0.35 + 0.5}s"}
            path={"M#{last_stage.x + 34},#{@pipeline_y} L#{target.x - 44},#{target.y}"} />
        </circle>
        <rect x={target.x - 44} y={target.y - 12} width="88" height="24" rx="12"
          fill="#1C1916" stroke="#FFB86C" stroke-width="1.2" stroke-opacity="0.55" class="dia-reveal"
          style={"transition:opacity 0.35s #{0.8 + i * 0.1}s"} />
        <text x={target.x} y={target.y + 4} text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#A89B8B"><%= target.label %></text>
      <% end %>

      <%!-- Step numbers --%>
      <%= for {stage, i} <- @stages_indexed do %>
        <text x={stage.x} y={@pipeline_y + 42} text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D" class="dia-reveal"><%= String.pad_leading(Integer.to_string(i + 1), 2, "0") %></text>
      <% end %>
    </svg>
    """
  end

  # -- Switch Diagram --
  # 4 tool nodes → Switch central → One Panel

  @switch_tools [
    %{label: "Cursor", y: 34},
    %{label: "Claude", y: 78},
    %{label: "Gemini", y: 122},
    %{label: "Cline", y: 166}
  ]

  @switch_cx 220
  @switch_cy 110

  def switch_diagram(assigns) do
    assigns =
      assigns
      |> assign(:tools, Enum.with_index(@switch_tools))
      |> assign(:scx, @switch_cx)
      |> assign(:scy, @switch_cy)

    ~H"""
    <svg
      viewBox="0 0 400 200" fill="none" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Lurus Switch: multiple AI tools unified into one panel"
      class="w-full h-full diagram-svg"
      id="switch-svg" phx-hook="DiagramReveal"
    >
      <ellipse cx={@scx} cy={@scy} rx="60" ry="50" fill="#FF8C69" opacity="0.06" class="dia-reveal" />

      <%!-- Tool nodes --%>
      <%= for {tool, i} <- @tools do %>
        <rect x="12" y={tool.y - 13} width="72" height="26" rx="6"
          fill="#1C1916" stroke="#FF8C69" stroke-width="1.2" stroke-opacity="0.55"
          class="dia-draw" style={"animation-delay:#{i * 120}ms"} />
        <text x="48" y={tool.y + 5} text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#A89B8B"><%= tool.label %></text>
        <line x1="86" y1={tool.y} x2={@scx - 36} y2={@scy}
          stroke="#FF8C69" stroke-width="1" stroke-dasharray="4 3" stroke-opacity="0.4"
          class="dia-draw-line" style={"animation-delay:#{280 + i * 100}ms"} />
        <circle r="2.5" fill="#FF8C69" opacity="0.85" class="dia-reveal">
          <animateMotion dur={"#{1.8 + i * 0.25}s"} repeatCount="indefinite" begin={"#{i * 0.35}s"}
            path={"M86,#{tool.y} L#{@scx - 36},#{@scy}"} />
        </circle>
      <% end %>

      <%!-- Central Switch node --%>
      <rect x={@scx - 36} y={@scy - 34} width="72" height="68" rx="12"
        fill="#141210" stroke="#FF8C69" stroke-width="2"
        class="dia-draw" style="animation-delay:500ms" />
      <rect x={@scx - 30} y={@scy - 28} width="60" height="56" rx="9"
        fill="none" stroke="#FF8C69" stroke-width="0.5" stroke-opacity="0.25" class="dia-reveal" />
      <text x={@scx} y={@scy - 6} text-anchor="middle" font-size="11" font-weight="700" font-family="ui-monospace,monospace" fill="#F5F0E8">Lurus</text>
      <text x={@scx} y={@scy + 10} text-anchor="middle" font-size="11" font-weight="700" font-family="ui-monospace,monospace" fill="#FF8C69">Switch</text>

      <%!-- Output arrow --%>
      <line x1={@scx + 36} y1={@scy} x2="344" y2={@scy}
        stroke="#FF8C69" stroke-width="1.5" stroke-dasharray="6 4" stroke-opacity="0.7"
        class="dia-draw-line" style="animation-delay:700ms" />
      <polygon points={"344,#{@scy - 6} 356,#{@scy} 344,#{@scy + 6}"} fill="#FF8C69" opacity="0.75" class="dia-reveal" />
      <circle r="2.5" fill="#FF8C69" opacity="0.9" class="dia-reveal">
        <animateMotion dur="1.4s" repeatCount="indefinite" begin="0.8s" path={"M#{@scx + 36},#{@scy} L344,#{@scy}"} />
      </circle>

      <%!-- Right label --%>
      <text x="363" y={@scy - 4} font-size="10" font-family="ui-monospace,monospace" fill="#A89B8B" class="dia-reveal">One</text>
      <text x="363" y={@scy + 10} font-size="10" font-family="ui-monospace,monospace" fill="#FF8C69" class="dia-reveal">Panel</text>
    </svg>
    """
  end

  # -- Lumen Diagram --
  # Agent execution flamechart / trace

  @lumen_nodes [
    %{label: "Agent.run", depth: 0, y: 28, bar_w: 440, dur: "342ms"},
    %{label: "Plan.generate", depth: 1, y: 68, bar_w: 200, dur: "145ms"},
    %{label: "LLM.call", depth: 2, y: 108, bar_w: 165, dur: "128ms"},
    %{label: "Execute.step", depth: 1, y: 148, bar_w: 140, dur: "67ms"},
    %{label: "Tool.search", depth: 2, y: 188, bar_w: 120, dur: "45ms"}
  ]

  @tree_lines [
    %{x1: 22, y1: 28, x2: 22, y2: 148},
    %{x1: 22, y1: 68, x2: 28, y2: 68},
    %{x1: 22, y1: 148, x2: 28, y2: 148},
    %{x1: 40, y1: 68, x2: 40, y2: 108},
    %{x1: 40, y1: 108, x2: 46, y2: 108},
    %{x1: 40, y1: 148, x2: 40, y2: 188},
    %{x1: 40, y1: 188, x2: 46, y2: 188}
  ]

  @lumen_particles [
    %{path: "M22,28 L22,68 L28,68", dur: "1.4s", begin: "0s"},
    %{path: "M40,68 L40,108 L46,108", dur: "1.2s", begin: "0.3s"},
    %{path: "M22,79 L22,148 L28,148", dur: "1.4s", begin: "0.55s"},
    %{path: "M40,148 L40,188 L46,188", dur: "1.2s", begin: "0.8s"}
  ]

  defp lumen_nx(depth), do: 10 + depth * 18

  def lumen(assigns) do
    assigns =
      assigns
      |> assign(:nodes, Enum.with_index(@lumen_nodes))
      |> assign(:tree_lines, @tree_lines)
      |> assign(:particles, @lumen_particles)

    ~H"""
    <svg
      viewBox="0 0 490 210" fill="none" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Lumen: Agent execution trace flamechart"
      class="w-full h-full diagram-svg"
      id="lumen-svg" phx-hook="DiagramReveal"
    >
      <ellipse cx="200" cy="108" rx="150" ry="80" fill="#FFE566" opacity="0.04" class="dia-reveal" />

      <%!-- Tree connector lines --%>
      <g stroke="#FFE566" stroke-width="0.9" stroke-opacity="0.22" class="dia-reveal">
        <%= for ln <- @tree_lines do %>
          <line x1={ln.x1} y1={ln.y1} x2={ln.x2} y2={ln.y2} />
        <% end %>
      </g>

      <%!-- Connector particles --%>
      <%= for p <- @particles do %>
        <circle r="2" fill="#FFE566" opacity="0.6" class="dia-reveal">
          <animateMotion dur={p.dur} repeatCount="indefinite" begin={p.begin} path={p.path} />
        </circle>
      <% end %>

      <%!-- Trace bars --%>
      <%= for {node, i} <- @nodes do %>
        <% nx = lumen_nx(node.depth) %>
        <rect x={nx} y={node.y - 11} width={node.bar_w} height="22" rx="4"
          fill="#141210" stroke="#FFE566"
          stroke-width={if node.depth == 0, do: "1.5", else: "1"}
          stroke-opacity={if node.depth == 0, do: "0.7", else: "0.4"}
          class="dia-draw" style={"animation-delay:#{i * 140}ms"} />
        <text x={nx + 8} y={node.y + 4} font-size="9.5" font-family="ui-monospace,monospace"
          fill={if node.depth == 0, do: "#F5F0E8", else: "#A89B8B"}
          font-weight={if node.depth == 0, do: "600", else: "400"}><%= node.label %></text>
        <text x={nx + node.bar_w - 6} y={node.y + 4} text-anchor="end" font-size="8.5" font-family="ui-monospace,monospace"
          fill="#FFE566" fill-opacity={if node.depth == 0, do: "0.9", else: "0.6"}><%= node.dur %></text>
        <circle r="2" fill="#FFE566" opacity="0.7" class="dia-reveal">
          <animateMotion dur={"#{1.6 + i * 0.18}s"} repeatCount="indefinite" begin={"#{i * 0.25 + 0.1}s"}
            path={"M#{nx},#{node.y} L#{nx + node.bar_w},#{node.y}"} />
        </circle>
      <% end %>
    </svg>
    """
  end

  # -- Ecosystem Map --
  # Radial product map with center hub

  @eco_nodes [
    %{id: "api", name: "Lurus API", tagline: "50+ 模型网关", color: "#4A9EFF", ring: :inner, angle: 0},
    %{id: "kova", name: "Kova", tagline: "Agent 引擎", color: "#B08EFF", ring: :inner, angle: 120},
    %{id: "switch", name: "Switch", tagline: "工具管理器", color: "#FF8C69", ring: :inner, angle: 240},
    %{id: "lucrum", name: "Lucrum", tagline: "AI 量化", color: "#7AFF89", ring: :outer, angle: 40},
    %{id: "creator", name: "Creator", tagline: "内容工厂", color: "#FFB86C", ring: :outer, angle: 110},
    %{id: "memx", name: "MemX", tagline: "AI 记忆", color: "#4AFFCB", ring: :outer, angle: 200},
    %{id: "lumen", name: "Lumen", tagline: "调试器", color: "#FFE566", ring: :outer, angle: 290}
  ]

  @eco_connections [
    {"api", "lucrum"}, {"api", "creator"}, {"kova", "lumen"},
    {"kova", "lucrum"}, {"switch", "memx"}, {"switch", "creator"}, {"api", "memx"}
  ]

  @eco_cx 300
  @eco_cy 200
  @inner_radius 110
  @outer_radius 170

  defp eco_node_pos(node) do
    r = if node.ring == :inner, do: @inner_radius, else: @outer_radius
    rad = (node.angle - 90) * :math.pi() / 180
    {Float.round(@eco_cx + r * :math.cos(rad), 1), Float.round(@eco_cy + r * :math.sin(rad), 1)}
  end

  def ecosystem_map(assigns) do
    nodes_map =
      @eco_nodes
      |> Enum.map(fn n ->
        {nx, ny} = eco_node_pos(n)
        {n.id, Map.merge(n, %{x: nx, y: ny})}
      end)
      |> Map.new()

    conn_paths =
      Enum.with_index(@eco_connections)
      |> Enum.map(fn {{from, to}, i} ->
        a = Map.get(nodes_map, from)
        b = Map.get(nodes_map, to)
        %{path: "M#{a.x},#{a.y} L#{b.x},#{b.y}", idx: i}
      end)

    nodes_list = Enum.with_index(Map.values(nodes_map))

    assigns =
      assigns
      |> assign(:eco_nodes, nodes_list)
      |> assign(:conn_paths, conn_paths)
      |> assign(:eco_cx, @eco_cx)
      |> assign(:eco_cy, @eco_cy)

    ~H"""
    <svg
      viewBox="0 0 600 400" fill="none" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Lurus product ecosystem map"
      class="w-full h-auto diagram-svg"
      id="ecosystem-map-svg" phx-hook="DiagramReveal"
    >
      <%!-- Connection lines --%>
      <%= for conn <- @conn_paths do %>
        <path d={conn.path} stroke="#2A2520" stroke-width="1" fill="none" stroke-dasharray="4 3"
          class="dia-draw-line" style={"animation-delay:#{300 + conn.idx * 100}ms;stroke-opacity:0.6"} />
      <% end %>

      <%!-- Center hub --%>
      <circle cx={@eco_cx} cy={@eco_cy} r="36" fill="var(--color-surface-overlay,#1C1916)" stroke="#D4A827" stroke-width="1.5" class="dia-draw" style="animation-delay:100ms" />
      <text x={@eco_cx} y={@eco_cy - 6} text-anchor="middle" fill="#D4A827" font-size="11" font-weight="700">Lurus</text>
      <text x={@eco_cx} y={@eco_cy + 10} text-anchor="middle" fill="#6B5D4D" font-size="8">AI Ecosystem</text>

      <%!-- Product nodes --%>
      <%= for {node, i} <- @eco_nodes do %>
        <% nr = if node.ring == :inner, do: 28, else: 24 %>
        <circle cx={node.x} cy={node.y} r={nr}
          fill="var(--color-surface-raised,#141210)" stroke={node.color} stroke-width="1.5"
          class="dia-reveal" style={"transition:opacity 0.5s #{0.2 + i * 0.08}s"} />
        <text x={node.x} y={node.y - 4} text-anchor="middle" fill={node.color} font-size="9" font-weight="600" class="dia-reveal"><%= node.name %></text>
        <text x={node.x} y={node.y + 8} text-anchor="middle" fill="#6B5D4D" font-size="7" class="dia-reveal"><%= node.tagline %></text>
      <% end %>
    </svg>
    """
  end
end
