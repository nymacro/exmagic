defmodule MagicTest do
  use ExUnit.Case
  doctest Magic

  test "gzip" do
    m = Magic.create
    assert Magic.buffer(m, <<31, 139, 8, 8, 154, 180, 2, 99, 0, 3, 120, 0, 75, 76, 74, 230, 2, 0, 78, 129, 136, 71, 4, 0, 0, 0>>) == {:ok, "application/gzip"}
  end

  test "server" do
    Magic.Server.start
    assert Magic.Server.buffer(<<31, 139, 8, 8, 154, 180, 2, 99, 0, 3, 120, 0, 75, 76, 74, 230, 2, 0, 78, 129, 136, 71, 4, 0, 0, 0>>) == {:ok, "application/gzip"}
  end

  test "badarg" do
    m = Magic.create
    assert_raise ArgumentError, fn ->
      Magic.buffer(m, 'abc') == :error
    end
  end
end
