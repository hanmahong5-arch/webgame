defmodule LurusWww.Data.Partners do
  @moduledoc false

  @partners [
    %{name: "OpenAI", color: "#10A37F"},
    %{name: "Anthropic", color: "#D4A27F"},
    %{name: "DeepSeek", color: "#4A9EFF"},
    %{name: "Google Gemini", color: "#4285F4"},
    %{name: "Mistral", color: "#FF7000"},
    %{name: "Meta Llama", color: "#0668E1"},
    %{name: "Qwen", color: "#6F42C1"},
    %{name: "Yi", color: "#00D4AA"},
    %{name: "Moonshot", color: "#8B5CF6"},
    %{name: "Zhipu GLM", color: "#3B82F6"},
    %{name: "Baichuan", color: "#EF4444"},
    %{name: "MiniMax", color: "#F59E0B"}
  ]

  def all, do: @partners
end
