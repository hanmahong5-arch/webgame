defmodule LurusWww.Chat.Stream do
  @moduledoc """
  Server-side SSE consumer for chat completions.
  Consumes SSE from api.lurus.cn and sends tokens to LiveView process.
  """

  @doc "Start streaming chat completion, sending tokens to `pid`"
  def start(messages, model, pid) do
    api_url = Application.get_env(:lurus_www, :api_url, "https://api.lurus.cn")
    api_key = Application.get_env(:lurus_www, :demo_api_key, "")

    url = "#{api_url}/v1/chat/completions"

    body =
      Jason.encode!(%{
        model: model,
        messages: messages,
        stream: true
      })

    headers = [
      {"content-type", "application/json"},
      {"authorization", "Bearer #{api_key}"},
      {"accept", "text/event-stream"}
    ]

    req = Finch.build(:post, url, headers, body)

    Task.start(fn ->
      ref = Finch.async_request(req, LurusWww.Finch)
      consume_sse(ref, pid, "")
    end)
  end

  defp consume_sse(ref, pid, buffer) do
    receive do
      {^ref, {:status, _}} ->
        consume_sse(ref, pid, buffer)

      {^ref, {:headers, _}} ->
        consume_sse(ref, pid, buffer)

      {^ref, {:data, data}} ->
        new_buffer = buffer <> data
        {events, remaining} = parse_sse_events(new_buffer)

        for event <- events do
          case parse_chat_delta(event) do
            {:ok, content} -> send(pid, {:chat_token, content})
            :done -> send(pid, :chat_done)
            :skip -> :ok
          end
        end

        consume_sse(ref, pid, remaining)

      {^ref, :done} ->
        send(pid, :chat_done)
    after
      30_000 ->
        send(pid, {:chat_error, :timeout})
    end
  end

  defp parse_sse_events(buffer) do
    lines = String.split(buffer, "\n\n")

    case List.pop_at(lines, -1) do
      {"", rest} -> {rest, ""}
      {incomplete, rest} -> {rest, incomplete}
    end
  end

  defp parse_chat_delta(event) do
    case String.trim_leading(event, "data: ") do
      "[DONE]" ->
        :done

      json_str ->
        case Jason.decode(json_str) do
          {:ok, %{"choices" => [%{"delta" => %{"content" => content}} | _]}} when is_binary(content) ->
            {:ok, content}

          _ ->
            :skip
        end
    end
  end
end
