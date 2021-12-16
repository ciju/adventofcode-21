defmodule AOC16 do
  import Enum, only: [at: 2]

  def solve_first(hex) do
    Base.decode16!(hex)
    |> decode_seq()
  end

  def solve_second(hex) do
    solve_first(hex)
    |> execute()
  end

  def execute([packet]) do
    execute(packet)
  end

  def execute(%{type: 4, data: data}), do: data

  def execute(%{type: type, data: data}) do
    nums = Enum.map(data, &execute/1)

    case type do
      0 -> nums |> Enum.sum()
      1 -> nums |> Enum.reduce(&(&1 * &2))
      2 -> nums |> Enum.min()
      3 -> nums |> Enum.max()
      5 -> if at(nums, 0) > at(nums, 1), do: 1, else: 0
      6 -> if at(nums, 0) < at(nums, 1), do: 1, else: 0
      7 -> if at(nums, 0) == at(nums, 1), do: 1, else: 0
    end
  end

  def decode_seq(bitstring, ls \\ []) do
    {packet, rest} = decode_packet(bitstring)

    case bits_to_int(rest) == 0 or rest == "" do
      true -> [packet | ls] |> Enum.reverse()
      false -> decode_seq(rest, [packet | ls])
    end
  end

  def decode_packet(<<ver::3, type::3, rest::bitstring>>) when type == 4 do
    {data, rest} = decode_literal(rest)

    {%{
       ver: ver,
       type: type,
       data: data
     }, rest}
  end

  def decode_packet(<<ver::3, type::3, 0::1, len::15, rest::bitstring>>) do
    <<data::bitstring-size(len), rest::bitstring>> = rest

    {%{
       ver: ver,
       type: type,
       data: decode_seq(data)
     }, rest}
  end

  def decode_packet(<<ver::3, type::3, 1::1, len::11, rest::bitstring>>) do
    {rest, packets} =
      for _i <- 1..len, reduce: {rest, []} do
        {rest, packets} ->
          {packet, rest} = decode_packet(rest)
          {rest, [packet | packets]}
      end

    {
      %{
        ver: ver,
        type: type,
        data: packets |> Enum.reverse()
      },
      rest
    }
  end

  def decode_literal(bitstring, literal \\ <<>>)

  def decode_literal(<<1::1, group::4, rest::bitstring>>, literal) do
    decode_literal(rest, <<literal::bitstring, group::4>>)
  end

  def decode_literal(<<0::1, group::4, rest::bitstring>>, literal) do
    <<literal::bitstring, group::4>>
    |> bits_to_int()
    |> then(&{&1, rest})
  end

  def bits_to_int(bits) do
    size = bit_size(bits)
    <<int::integer-size(size)>> = bits
    int
  end

  def sum_ver(%{data: data, ver: ver}) when is_list(data) do
    Enum.map(data, &sum_ver/1)
    |> Enum.sum()
    |> then(&(&1 + ver))
  end

  def sum_ver(%{data: data, ver: ver}) when is_number(data) do
    ver
  end

  def sum_ver(ls) when is_list(ls) do
    Enum.map(ls, &sum_ver/1)
    |> Enum.sum()
  end
end

[
  {"D2FE28", 6},
  {"38006F45291200", 9},
  {"EE00D40C823060", 14},
  {"8A004A801A8002F478", 16},
  {"620080001611562C8802118E34", 12},
  {"C0015000016115A2E0802F182340", 23},
  {"A0016C880162017C3686B18A3D4780", 31}
]
|> Enum.map(fn {bin, count} ->
  AOC16.solve_first(bin)
  |> AOC16.sum_ver()
  |> IO.inspect(label: "sol: #{count}")
end)

{:ok, content} = File.read("16.input")

AOC16.solve_first(content)
|> AOC16.sum_ver()
|> IO.inspect(label: "sol: 1012")

[
  {"C200B40A82", 3},
  {"04005AC33890", 54},
  {"880086C3E88112", 7},
  {"CE00C43D881120", 9},
  {"D8005AC2A8F0", 1},
  {"F600BC2D8F", 0},
  {"9C005AC2F8F0", 0},
  {"9C0141080250320F1802104A08", 1}
]
|> Enum.map(fn {bin, count} ->
  AOC16.solve_second(bin)
  |> IO.inspect(label: "sol: #{count}")
end)

AOC16.solve_second(content)
|> IO.inspect(label: "sol: 2223947372407")
