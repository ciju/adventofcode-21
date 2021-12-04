defmodule AOC3 do
  def input(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&Enum.map(&1, fn c -> c - ?0 end))
  end

  def solve_first(file), do: solve(file, &solve_first/2)
  def solve_second(file), do: solve(file, &solve_second/2)

  def solve(file, op) do
    input(file)
    |> then(fn lss -> [[lss, &max_bit/1], [lss, &min_bit/1]] end)
    |> Enum.map(fn args -> apply(op, args) end)
    |> Enum.map(&to_int/1)
    |> then(fn [max, min] -> max * min end)
  end

  defp solve_first(lss, op) do
    for i <- 0..(length(Enum.at(lss, 0)) - 1) do
      get_pos_bit(lss, i, op)
    end
  end

  defp solve_second(lss, op, bit \\ 0)
  defp solve_second([bs], _op, _bit), do: bs

  defp solve_second(lss, op, bit) do
    filter_bit = get_pos_bit(lss, bit, op)

    lss
    |> Enum.filter(&(Enum.at(&1, bit) == filter_bit))
    |> solve_second(op, bit + 1)
  end

  def get_pos_bit(lss, pos, op) do
    lss
    |> Enum.map(&Enum.at(&1, pos))
    |> then(&op.(&1))
  end

  def max_bit(ls) do
    ls
    |> Enum.count(&(&1 == 1))
    |> then(&if &1 >= length(ls) / 2, do: 1, else: 0)
  end

  def min_bit(ls) do
    if max_bit(ls) == 1, do: 0, else: 1
  end

  def to_int(ls) do
    ls
    |> Enum.map(&(&1 + ?0))
    |> List.to_integer(2)
  end
end

AOC3.solve_first("./3.test.input")
|> IO.inspect()

AOC3.solve_first("./3.input")
|> IO.inspect()

AOC3.solve_second("./3.test.input")
|> IO.inspect()

AOC3.solve_second("./3.input")
|> IO.inspect()
