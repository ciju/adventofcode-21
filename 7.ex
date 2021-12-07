defmodule AOC7 do
  def input(file) do
    {:ok, content} = File.read(file)

    content
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solve_first(file), do: solve(input(file), & &1)
  def solve_second(file), do: solve(input(file), &cost/1)

  def cost(n), do: div(n * (n + 1), 2)

  def solve(poss, cost_fn) do
    poss
    |> Enum.min_max()
    |> then(&(elem(&1, 0)..elem(&1, 1)))
    |> Enum.map(fn v ->
      Enum.map(poss, fn e -> cost_fn.(abs(e - v)) end)
      |> Enum.sum()
    end)
    |> Enum.min()
  end
end

AOC7.solve_first("./7.test.input")
|> IO.inspect(label: "sol:37")

AOC7.solve_first("./7.input")
|> IO.inspect(label: "sol:364898")

AOC7.solve_second("./7.test.input")
|> IO.inspect(label: "sol:168")

AOC7.solve_second("./7.input")
|> IO.inspect(label: "sol:104149091")
