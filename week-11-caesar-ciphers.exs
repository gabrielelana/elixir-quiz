defmodule CaesarCiphers do

  def encode(<<cp::utf8, rest::binary>>, shift) do
    <<(cp+shift)::utf8, (encode(rest, shift))::binary>>
  end
  def encode(<<>>, shift) do
    <<>>
  end

end


ExUnit.start

defmodule CaesarCiphers.Test do
  use ExUnit.Case

  test "encode a string" do
    assert CaesarCiphers.encode("aaa", 1) == "bbb"
    assert CaesarCiphers.encode("aaa", 2) == "ccc"
  end

  test "encode works with codepoints" do
    assert CaesarCiphers.encode("←", 1) == "↑"
  end
end
