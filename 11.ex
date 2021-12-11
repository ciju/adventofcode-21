defmodule AOC11 do
  def input(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, ridx}, acc ->
      row
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {val, cidx}, acc ->
        Map.put(acc, {ridx, cidx}, val - ?0)
      end)
    end)
  end

  def solve_first(input) do
    Enum.reduce(0..99, {input, 0}, fn _, {acc, flashed} ->
      increment_all(acc)
      |> flash_octos()
      |> then(&{elem(&1, 0), flashed + elem(&1, 1)})
    end)
    |> then(&elem(&1, 1))
  end

  def solve_second(input) do
    {rows, cols} = input |> Map.keys() |> Enum.max()
    total_octos = (rows + 1) * (cols + 1)
    solve_second(input, total_octos)
  end

  def solve_second(input, total, step \\ 0, flashes \\ 0)

  def solve_second(_input, total, step, flashes) when flashes == total, do: step

  def solve_second(input, total, step, _flashes) do
    increment_all(input)
    |> flash_octos()
    |> then(fn {octos, flashed} -> solve_second(octos, total, step + 1, flashed) end)
  end

  def increment_all(octos) do
    Enum.reduce(octos, {octos, []}, fn {idx, val}, {acc, to_flash} ->
      acc = Map.put(acc, idx, val + 1)
      to_flash = if val + 1 == 10, do: [idx | to_flash], else: to_flash
      {acc, to_flash}
    end)
  end

  def increment_indexes(octos, ls, ignore) do
    Enum.reduce(ls, {octos, []}, fn idx, {acc, to_flash} ->
      val = octos[idx]

      if val == 10 or idx in ignore do
        {acc, to_flash}
      else
        to_flash = if val + 1 == 10, do: [idx | to_flash], else: to_flash
        {Map.put(acc, idx, val + 1), to_flash}
      end
    end)
  end

  def flash_octos({octos, to_flash}), do: flash_octos({octos, to_flash}, MapSet.new())
  def flash_octos({octos, []}, flashed), do: {octos, MapSet.size(flashed)}

  def flash_octos({octos, [h | t]}, flashed) do
    flashed = MapSet.put(flashed, h)

    # increment neighbours
    neighs =
      neighbours(h)
      |> Enum.filter(&Map.get(octos, &1))
      |> Enum.filter(&(!(&1 in flashed)))

    {octos, to_flash} = increment_indexes(Map.put(octos, h, 0), neighs, flashed)

    flash_octos({octos, Enum.dedup(t ++ to_flash)}, flashed)
  end

  def print_octos(octos) do
    Enum.map(0..9, fn r ->
      Enum.map(0..9, fn c -> if octos[{r, c}] == 10, do: "x", else: octos[{r, c}] end)
      |> Enum.join(",")
    end)
    |> Enum.join("\n")
    |> IO.puts()

    IO.puts("\n")
  end

  def neighbours({r, c}),
    do: [
      {r - 1, c},
      {r + 1, c},
      {r, c - 1},
      {r, c + 1},
      {r + 1, c + 1},
      {r - 1, c - 1},
      {r - 1, c + 1},
      {r + 1, c - 1}
    ]
end

AOC11.input("11.test.input")
|> AOC11.solve_first()
|> IO.inspect(label: "sol: 1656")

AOC11.input("11.input")
|> AOC11.solve_first()
|> IO.inspect(label: "sol: 1739")

AOC11.input("11.test.input")
|> AOC11.solve_second()
|> IO.inspect(label: "sol: 195")

AOC11.input("11.input")
|> AOC11.solve_second()
|> IO.inspect(label: "sol: 324")
