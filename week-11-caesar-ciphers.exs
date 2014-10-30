defmodule CaesarCiphers do
  @alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  defmacro new(shift) do
    quote do
      cipher_module = Module.concat(CaesarCiphers, "WithShiftOf#{unquote(shift)}")
      defmodule cipher_module do
        def encode(<<"A"::utf8, rest::binary>>) do
          <<"X"::utf8, encode(rest)::binary>>
        end
        def encode(<<character::utf8, rest::binary>>) do
          <<character::utf8, rest::binary>>
        end
        def encode(<<>>) do
          <<>>
        end
      end
      cipher_module
    end
  end
end


ExUnit.start

defmodule CaesarCiphers.Test do
  use ExUnit.Case
  require CaesarCiphers

  test "create a cipher for a particular shift" do
    cipher = CaesarCiphers.new(3)
    assert :code.is_loaded(CaesarCiphers.WithShiftOf3) == {:file, :in_memory}
    assert cipher.encode("A") == "X"
  end
end
