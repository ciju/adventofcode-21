defmodule PQ do
  defstruct key_map: %{}, size: 0, list: []

  def new() do
    %PQ{}
  end

  def pop(%PQ{size: 0}), do: nil

  def pop(%PQ{key_map: key_map, list: list, size: size}) do
    {{mk, mv}, list} = pop_min_rec(tl(list), hd(list))

    {{mk, mv},
     %PQ{
       key_map: Map.delete(key_map, mk),
       list: list,
       size: size - 1
     }}
  end

  def pop_min_rec(ls, min, acc \\ [])
  def pop_min_rec([], min, acc), do: {min, acc}

  def pop_min_rec([h | rest], m, acc) do
    {min, other} = if elem(h, 1) < elem(m, 1), do: {h, m}, else: {m, h}

    pop_min_rec(rest, min, [other | acc])
  end

  def upsert(%PQ{} = pq, key, val) do
    %{key_map: map} = pq

    if Map.has_key?(map, key) do
      # update value for key
      list = update_key(pq, key, val)

      Map.put(pq, :list, list)
    else
      %{key_map: map, list: list, size: size} = pq

      %PQ{
        key_map: Map.put(map, key, true),
        list: [{key, val} | list],
        size: size + 1
      }
    end
  end

  def update_key(%{list: list}, key, val), do: update_rec(list, key, val)

  def update_rec(lst, key, val, acc \\ [])
  def update_rec([{key, hv} | t], key, val, acc), do: [{key, min(val, hv)} | t] ++ acc
  def update_rec([h | t], key, val, acc), do: update_rec(t, key, val, [h | acc])
end

defmodule AOC15 do
  import Enum, only: [at: 2]

  def input(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn s ->
      s |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end

  def roll(val) when val > 9, do: val - 9
  def roll(val), do: val

  def expand(matrix) do
    {map, {rmax, cmax}} = pos_map(matrix)

    for r <- 0..4, c <- 0..4, row <- 0..rmax, col <- 0..cmax, reduce: map do
      acc ->
        pos = {r * (rmax + 1) + row, c * (cmax + 1) + col}
        val = roll(r + c + map[{row, col}])
        Map.put(acc, pos, val)
    end
    |> then(&{&1, {5 * (rmax + 1) - 1, 5 * (cmax + 1) - 1}})
  end

  def pos_map(matrix) do
    rmax = length(matrix) - 1
    cmax = length(at(matrix, 0)) - 1

    # %{ {row, col} => value }
    for row <- 0..rmax, col <- 0..cmax, reduce: %{} do
      acc -> Map.put(acc, {row, col}, matrix |> at(row) |> at(col))
    end
    |> then(&{&1, {rmax, cmax}})
  end

  def solve_first(input) do
    {map, dest} = pos_map(input)
    pq = PQ.new() |> PQ.upsert({0, 0}, 0)
    solve_rec(map, pq, %{}, dest)
  end

  def solve_second(input) do
    {map, dest} = expand(input)
    pq = PQ.new() |> PQ.upsert({0, 0}, 0)
    solve_rec(map, pq, %{}, dest)
  end

  def solve_rec(map, pq, popped, dest) do
    {{{row, col} = cur, val}, pq} = pq |> PQ.pop()

    if {row, col} == dest do
      val
    else
      pq =
        [{row, col + 1}, {row + 1, col}, {row - 1, col}, {row, col - 1}]
        |> Enum.filter(&(!popped[&1]))
        |> Enum.filter(&map[&1])
        |> Enum.reduce(pq, fn key, pq ->
          PQ.upsert(pq, key, map[key] + val)
        end)

      solve_rec(map, pq, Map.put(popped, cur, true), dest)
    end
  end
end

AOC15.input("15.test.input")
|> AOC15.solve_first()
|> IO.inspect(label: "sol: 40")

AOC15.input("15.input")
|> AOC15.solve_first()
|> IO.inspect(label: "sol: 755")

AOC15.input("15.test.input")
|> AOC15.solve_second()
|> IO.inspect(label: "sol: 315")

AOC15.input("15.input")
|> AOC15.solve_second()
|> IO.inspect(label: "sol: 3016")
