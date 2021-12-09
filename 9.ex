defmodule AOC9 do
  def input(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(
      &(String.split(&1, "", trim: true)
        |> Enum.map(fn s -> String.to_integer(s) end)
        |> List.to_tuple())
    )
    |> List.to_tuple()
  end

  def solve_first(input) do
    row_max = tuple_size(input) - 1
    get_elem = get_elem_gen(input)

    0..row_max
    |> Enum.flat_map(&collect_row_lows(input, &1))
    |> Enum.map(&(1 + get_elem.(&1)))
    |> Enum.sum()
  end

  def solve_second(input) do
    0..(tuple_size(input) - 1)
    |> Enum.flat_map(&collect_row_lows(input, &1))
    |> Enum.map(&basin_size(input, &1))
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(&(&1 * &2))
  end

  def collect_row_lows(input, row) do
    col_max = tuple_size(elem(input, 0)) - 1

    get_elem = get_elem_gen(input)

    Enum.reduce(0..col_max, [], fn col, lows ->
      u = get_elem.({row - 1, col})
      d = get_elem.({row + 1, col})
      l = get_elem.({row, col - 1})
      r = get_elem.({row, col + 1})

      v = get_elem.({row, col})

      if [u, d, l, r] |> Enum.all?(&(v < &1)) do
        [{row, col} | lows]
      else
        lows
      end
    end)
  end

  def basin_size(table, point), do: basin_size_rec(table, [point])
  def basin_size_rec(table, points, visited \\ %{}, size \\ 0)
  def basin_size_rec(_table, [], _visited, size), do: size

  def basin_size_rec(table, [h | t], visited, size) do
    neighs =
      basin_neighs(table, h)
      |> Enum.filter(&(!visited[&1]))

    visited =
      neighs
      |> Enum.map(&{&1, true})
      |> Enum.into(%{})
      |> Map.merge(visited)
      |> Map.merge(%{h => true})

    basin_size_rec(table, neighs ++ t, visited, size + 1)
  end

  def basin_neighs(table, {row, col}) do
    get_elem = get_elem_gen(table)

    [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}]
    |> Enum.map(&{&1, get_elem.(&1)})
    |> Enum.filter(&(elem(&1, 1) != nil and elem(&1, 1) != 9))
    |> Enum.map(&elem(&1, 0))
  end

  def get_elem_gen(table) do
    col_max = tuple_size(elem(table, 0)) - 1
    row_max = tuple_size(table) - 1

    fn {row, col} ->
      if row > row_max or col > col_max or row < 0 or col < 0 do
        # num < nil
        nil
      else
        table |> elem(row) |> elem(col)
      end
    end
  end
end

AOC9.input("9.test.input")
|> AOC9.solve_first()
|> IO.inspect(label: "sol: 15")

AOC9.input("9.input")
|> AOC9.solve_first()
|> IO.inspect(label: "sol: 444")

AOC9.input("9.test.input")
|> AOC9.solve_second()
|> IO.inspect(label: "sol: 1134")

AOC9.input("9.input")
|> AOC9.solve_second()
|> IO.inspect(label: "sol: 1168440")
