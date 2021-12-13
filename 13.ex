defmodule AOC13 do
  def input(file) do
    {:ok, content} = File.read(file)

    [pos, folds] =
      content
      |> String.split("\n\n", trim: true)

    pos =
      pos
      |> String.split("\n", trim: true)
      |> Enum.map(fn ps ->
        [x, y] = String.split(ps, ",", trim: true)
        %{x: String.to_integer(x), y: String.to_integer(y)}
      end)

    folds =
      folds
      |> String.split("\n", trim: true)
      |> Enum.map(fn fold ->
        case fold do
          "fold along x=" <> x -> {:x, String.to_integer(x)}
          "fold along y=" <> y -> {:y, String.to_integer(y)}
        end
      end)

    {pos, folds}
  end

  def solve_first({pos, folds}) do
    fold(pos, Enum.at(folds, 0))
  end

  def solve_second({pos, folds}) do
    Enum.reduce(folds, pos, &fold(&2, &1))
    |> tap(&print(&1))
  end

  def fold(points, {axis, fold_at}) do
    points
    |> Enum.map(fn pt ->
      cond do
        pt[axis] < fold_at -> pt
        pt[axis] == fold_at -> nil
        pt[axis] > fold_at -> %{pt | axis => 2 * fold_at - pt[axis]}
      end
    end)
    |> Enum.filter(& &1)
    |> Enum.uniq()
  end

  def len(points, axis) do
    (Enum.map(points, & &1[axis]) |> Enum.max()) + 1
  end

  def print(points) do
    x_max = len(points, :x) - 1
    y_max = len(points, :y) - 1

    map =
      points
      |> Enum.map(&Map.values/1)
      |> Enum.map(&{&1, true})
      |> Enum.into(%{})

    res =
      for y <- 0..y_max do
        for x <- 0..x_max do
          if Map.get(map, [x, y]), do: "#", else: "."
        end
        |> Enum.join("")
      end
      |> Enum.join("\n")

    IO.puts(res)
    IO.puts("\n")
  end
end

AOC13.input("13.test.input")
|> AOC13.solve_first()
|> Enum.count()
|> IO.inspect(label: "sol: 17")

AOC13.input("13.input")
|> AOC13.solve_first()
|> Enum.count()
|> IO.inspect(label: "sol: 942")

AOC13.input("13.test.input")
|> AOC13.solve_second()

"""
#####
#...#
#...#
#...#
#####
"""

AOC13.input("13.input")
|> AOC13.solve_second()

"""
..##.####..##..#..#..##..###..###..###.
...#....#.#..#.#..#.#..#.#..#.#..#.#..#
...#...#..#....#..#.#..#.#..#.#..#.###.
...#..#...#.##.#..#.####.###..###..#..#
#..#.#....#..#.#..#.#..#.#....#.#..#..#
.##..####..###..##..#..#.#....#..#.###.
"""
