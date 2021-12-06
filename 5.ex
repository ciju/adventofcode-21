defmodule AOC5 do
  def solve_first(lines), do: solve(lines)
  def solve_second(lines), do: solve(lines, _include_diagonal? = true)

  def solve(lines, include_diagonal? \\ false) do
    lines
    |> Enum.reduce(%{}, fn [[x1, y1], [x2, y2]], acc ->
      points =
        cond do
          x1 == x2 ->
            Enum.map(y1..y2, &{x1, &1})

          y1 == y2 ->
            Enum.map(x1..x2, &{&1, y1})

          include_diagonal? and abs(x1 - x2) == abs(y1 - y2) ->
            Enum.zip(x1..x2, y1..y2)

          true ->
            []
        end

      Enum.reduce(points, acc, fn key, acc ->
        Map.merge(acc, %{key => Map.get(acc, key, 0) + 1})
      end)
    end)
    |> Enum.count(fn {_pos, count} -> count > 1 end)
  end

  def input(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split(" -> ", trim: true)
    |> Enum.map(&String.split(&1, ",", trim: true))
    |> Enum.map(&Enum.map(&1, fn n -> String.to_integer(n) end))
  end
end

AOC5.input("./5.test.input")
|> AOC5.solve_first()
|> IO.inspect(label: "count:4")

AOC5.input("./5.input")
|> AOC5.solve_first()
|> IO.inspect(label: "count:5145")

IO.puts("\n")

AOC5.input("./5.test.input")
|> AOC5.solve_second()
|> IO.inspect(label: "count:12")

AOC5.input("./5.input")
|> AOC5.solve_second()
|> IO.inspect(label: "count:16518")
