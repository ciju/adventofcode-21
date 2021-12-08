defmodule AOC8 do
  def input(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [s, b] = line |> String.split(" | ") |> Enum.map(&String.split(&1, " "))

    [Enum.map(s, &normalize/1), Enum.map(b, &normalize/1)]
  end

  def normalize(s), do: String.to_charlist(s) |> Enum.sort()

  def solve_first(input) do
    input
    |> Enum.map(fn [s, b] -> b end)
    |> Enum.map(&Enum.count(&1, fn v -> length(v) in [2, 4, 3, 7] end))
    |> Enum.sum()
  end

  def solve_second(input) do
    input
    |> Enum.map(&resolve_digits/1)
    |> Enum.sum()
  end

  def resolve_digits([obs, signal]) do
    [one, seven, four, _, _, _, _, _, _, eight] =
      nums =
      obs
      |> Enum.sort(&(length(&1) <= length(&2)))

    seg_5s = nums |> Enum.filter(&(length(&1) == 5))
    seg_6s = nums |> Enum.filter(&(length(&1) == 6))

    three = seg_5s |> Enum.find(&(length(one -- &1) == 0))
    nine = seg_6s |> Enum.find(&(length(intersection(&1, four)) == 4))

    zero = (seg_6s -- [nine]) |> Enum.find(&(length(intersection(&1, one)) == 2))
    [six] = seg_6s -- [nine, zero]
    five = (seg_5s -- [three]) |> Enum.find(&(length(nine -- &1) == 1))
    [two] = seg_5s -- [three, five]

    Enum.map(signal, fn s ->
      [zero, one, two, three, four, five, six, seven, eight, nine]
      |> Enum.with_index()
      |> Enum.find(&(s == elem(&1, 0)))
      |> then(&elem(&1, 1))
    end)
    |> then(fn [a, b, c, d] -> a * 1000 + b * 100 + c * 10 + d end)
  end

  def intersection(a, b) do
    a -- a -- b
  end
end

AOC8.input("8.test.input")
|> AOC8.solve_first()
|> IO.inspect(label: "sol:26")

AOC8.input("8.input")
|> AOC8.solve_first()
|> IO.inspect(label: "sol:456")

AOC8.input("8.test.input")
|> AOC8.solve_second()
|> IO.inspect(label: "sol: 61229")

AOC8.input("8.input")
|> AOC8.solve_second()
|> IO.inspect(label: "sol: 1091609")
