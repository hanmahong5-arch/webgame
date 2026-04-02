defmodule LurusWww.Data.ProductsTest do
  use ExUnit.Case, async: true

  alias LurusWww.Data.Products

  test "all/0 returns 9 products" do
    products = Products.all()
    assert length(products) == 9
    assert Enum.all?(products, &is_map/1)
  end

  test "by_id/1 finds product" do
    product = Products.by_id("api")
    assert product.name == "Lurus API"
  end

  test "by_id/1 returns nil for unknown" do
    assert Products.by_id("nonexistent") == nil
  end

  test "for_audience/1 filters correctly" do
    explorers = Products.for_audience(:explorer)
    assert length(explorers) > 0
    assert Enum.all?(explorers, &Map.has_key?(&1, :cta))
  end

  test "nav_products/0 groups by category" do
    %{consumer: c, infra: i, dev: d} = Products.nav_products()
    assert length(c) > 0
    assert length(i) > 0
    assert length(d) > 0
  end

  test "footer_products/0 returns all three groups" do
    %{explorers: e, entrepreneurs: en, builders: b} = Products.footer_products()
    assert length(e) > 0
    assert length(en) > 0
    assert length(b) > 0
  end
end
