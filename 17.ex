defmodule AOC17 do
  def solve_first({x_range, y_range}) do
    y_range
    |> Enum.min()
    |> then(&sum_till(0 - &1 - 1))
  end

  def sum_till(n), do: div(n * (n + 1), 2)

  def solve_second({x_range, y_range}) do
    max_steps = x_range |> Enum.max() |> max_steps()

    x_vals =
      for i <- 1..max_steps do
        {i, start_for_steps(Enum.min_max(x_range), i)}
      end
      |> Enum.into(%{})

    y_vals =
      for i <- 1..max_steps do
        {i, start_for_steps(Enum.min_max(y_range), i)}
      end
      |> Enum.into(%{})

    all_except_drops =
      y_vals
      |> Map.merge(x_vals, fn _k, v1, v2 ->
        for i <- v1, j <- v2, do: {j, i}
      end)
      |> Map.values()
      |> Enum.flat_map(& &1)

    drops =
      y_vals
      |> Enum.flat_map(fn {i, range} -> Enum.into(range, []) end)
      |> Enum.uniq()
      |> Enum.map(fn n -> 0 - (n + 1) end)
      |> Enum.filter(&(&1 >= 0))
      |> Enum.flat_map(fn y ->
        x_vals[max_steps]
        |> Enum.map(fn x -> {x, y} end)
      end)

    (all_except_drops ++ drops)
    |> Enum.uniq()
    |> Enum.count()
  end

  def max_steps(target) do
    (1 + target * 8)
    |> :math.sqrt()
    |> then(&ceil((-1 + &1) / 2))
  end

  def start_for_steps({min, max}, steps) do
    calc = fn steps, target -> target / steps + (steps - 1) / 2 end

    ceil(calc.(steps, min))..floor(calc.(steps, max))
  end
end

test_input = {20..30, -10..-5}
input = {143..177, -106..-71}

AOC17.solve_first(test_input)
|> IO.inspect(label: "sol: 45")

AOC17.solve_first(input)
|> IO.inspect(label: "sol: 5565")

AOC17.solve_second(test_input)
|> IO.inspect(label: "sol: 112")

AOC17.solve_second(input)
|> IO.inspect(label: "sol: 2118")
