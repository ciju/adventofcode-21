defmodule AOC2 do
  def read(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
  end

  def solve(lines) do
    lines
    |> Enum.map(&map_line/1)
    |> Enum.reduce({0, 0, 0}, fn {h, a}, {acc_h, acc_a, acc_d} ->
      {acc_h + h, acc_a + a, acc_d + h * acc_a}
    end)
    |> then(fn {h, _a, d} -> h * d end)
  end

  def map_line("forward " <> vals), do: {String.to_integer(vals), 0}
  def map_line("up " <> vals), do: {0, -String.to_integer(vals)}
  def map_line("down " <> vals), do: {0, String.to_integer(vals)}
end
