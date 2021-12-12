defmodule AOC12 do
  def input(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "-", trim: true))
    |> make_map()
  end

  def make_map(lss, map \\ %{})
  def make_map([], map), do: map

  def make_map([[ca, cb] | rest], map) do
    map =
      map
      |> Map.update(ca, [cb], &[cb | &1])
      |> Map.update(cb, [ca], &[ca | &1])

    make_map(rest, map)
  end

  def solve_first(map) do
    solve_first_rec(map, "start", map["start"], MapSet.new(["start"]))
  end

  def solve_first_rec(map, node, sibs, visited, count \\ 0)

  def solve_first_rec(map, "end", _, _, count), do: count + 1

  def solve_first_rec(map, _, [], _, count), do: count

  def solve_first_rec(map, node, [s | rest], visited, count) do
    if MapSet.member?(visited, s) do
      solve_first_rec(map, node, rest, visited, count)
    else
      count = solve_first_rec(map, node, rest, visited, count)
      visited = if small_cave?(s), do: MapSet.put(visited, s), else: visited

      solve_first_rec(map, s, map[s], visited, count)
    end
  end

  def solve_second(map) do
    solve_second_rec(map, "start", map["start"], %{"start" => 1})
  end

  def solve_second_rec(count \\ 0, map, node, sibs, visited, small_twice? \\ false)

  def solve_second_rec(count, map, "end", _, _, _), do: count + 1

  def solve_second_rec(count, map, _, [], _, _), do: count

  def solve_second_rec(count, map, node, [s | rest], visited, small_twice?) do
    cond do
      not small_cave?(s) ->
        # big caves
        solve_second_rec(count, map, node, rest, visited, small_twice?)
        |> solve_second_rec(map, s, map[s], visited, small_twice?)

      visited[s] == 2 or
        (visited[s] == 1 and s in ["start", "end"]) or
          (small_twice? and visited[s] == 1) ->
        # visited twice or start, end or visited once (with one small visited
        # twice)
        solve_second_rec(count, map, node, rest, visited, small_twice?)

      small_twice? ->
        # small cave, and once cave was visited twice
        solve_second_rec(count, map, node, rest, visited, true)
        |> solve_second_rec(map, s, map[s], visit(s, visited), true)

      true ->
        new_visit = visit(s, visited)

        solve_second_rec(count, map, node, rest, visited, false)
        |> solve_second_rec(map, s, map[s], new_visit, new_visit[s] == 2)
    end
  end

  def visit(node, visited) do
    Map.update(visited, node, 1, &(&1 + 1))
  end

  def small_cave?(s) do
    char = s |> String.to_charlist() |> Enum.at(0)
    char >= ?a and char <= ?z
  end
end

AOC12.input("12.test.input")
|> AOC12.solve_first()
|> IO.inspect(label: "sol: 10")

AOC12.input("12.test-2.input")
|> AOC12.solve_first()
|> IO.inspect(label: "sol: 19")

AOC12.input("12.test-3.input")
|> AOC12.solve_first()
|> IO.inspect(label: "sol: 226")

AOC12.input("12.input")
|> AOC12.solve_first()
|> IO.inspect(label: "sol: 3563")

IO.puts("\n")

AOC12.input("12.test.input")
|> AOC12.solve_second()
|> IO.inspect(label: "sol: 36")

AOC12.input("12.test-2.input")
|> AOC12.solve_second()
|> IO.inspect(label: "sol: 103")

AOC12.input("12.test-3.input")
|> AOC12.solve_second()
|> IO.inspect(label: "sol: 3509")

AOC12.input("12.input")
|> AOC12.solve_second()
|> IO.inspect(label: "sol: 105453")
