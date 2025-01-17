defmodule ExWeb3EcRecover.SignedType.BinaryEncoder do
  @moduledoc """
  This module defines an encoder that expects all binaries to be
  to be parsed Elixir binaries and not strings.
  """

  @behaviour ExWeb3EcRecover.SignedType.Encoder

  def encode_value(type, value) when type in ["bytes", "string"], do: ExKeccak.hash_256(value)

  def encode_value("int" <> bytes_length, value),
    do: encode_value_atomic("int", bytes_length, value)

  def encode_value("uint" <> bytes_length, value),
    do: encode_value_atomic("uint", bytes_length, value)

  def encode_value("bytes" <> bytes_length, value),
    do: encode_value_atomic("bytes", bytes_length, value)

  def encode_value("bool", value),
    do: ABI.TypeEncoder.encode_raw([value], [:bool], :standard)

  def encode_value("address", value),
    do: ABI.TypeEncoder.encode_raw([value], [:address], :standard)

  def encode_value_atomic(type, bytes_length, value) do
    case Integer.parse(bytes_length) do
      {number, ""} ->
        ABI.TypeEncoder.encode_raw([value], [{String.to_existing_atom(type), number}], :standard)

      :error ->
        raise "Malformed type `#{type}` in types, with value #{value}"
    end
  end
end
