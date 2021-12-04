defmodule AOC1 do
  def read(file) do
    {:ok, content} = File.read(file)
    content |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)
  end

  def solve([h|t]) do
    Enum.zip([h|t], t)
    |> Enum.reduce(0, fn {prev, curr}, count ->
      count + if prev < curr, do: 1, else: 0
    end)
  end

  def solve3([a|[b|t]]) do
    Enum.zip([[a|[b|t]], [b|t], t])
    |> Enum.map(fn {a, b, c} -> a + b + c end)
    |> solve()
  end
end
