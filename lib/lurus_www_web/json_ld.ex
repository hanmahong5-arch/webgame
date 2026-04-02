defmodule LurusWwwWeb.JsonLd do
  @moduledoc false

  def organization do
    %{
      "@context" => "https://schema.org",
      "@type" => "SoftwareApplication",
      "name" => "Lurus API",
      "applicationCategory" => "DeveloperApplication",
      "operatingSystem" => "Web",
      "description" =>
        "Complete AI infrastructure ecosystem — API gateway, Agent SDK, quantitative trading, content factory, and persistent memory. 7 products covering every AI scenario.",
      "url" => "https://www.lurus.cn",
      "offers" => %{
        "@type" => "Offer",
        "price" => "0",
        "priceCurrency" => "CNY",
        "description" => "Free tier available"
      },
      "provider" => %{
        "@type" => "Organization",
        "name" => "Lurus Technology",
        "url" => "https://www.lurus.cn"
      }
    }
    |> Jason.encode!()
  end
end
