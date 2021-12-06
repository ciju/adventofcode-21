defmodule AOC6 do
  def input(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solve_first(input, days \\ 18) do
    counts = count_map(days)

    input
    |> Enum.map(&counts[{days, &1}])
    |> Enum.sum()
  end

  def count_map(days) do
    for day <- 2..days, gen <- 0..8, reduce: day_1_counts() do
      acc ->
        val =
          if gen == 0 do
            acc[{day - 1, 6}] + acc[{day - 1, 8}]
          else
            acc[{day - 1, gen - 1}]
          end

        Map.merge(acc, %{{day, gen} => val})
    end
  end

  def day_1_counts do
    %{
      {1, 0} => 2,
      {1, 1} => 1,
      {1, 2} => 1,
      {1, 3} => 1,
      {1, 4} => 1,
      {1, 5} => 1,
      {1, 6} => 1,
      {1, 7} => 1,
      {1, 8} => 1
    }
  end
end

AOC6.input("./6.test.input")
|> AOC6.solve_first(80)
|> IO.inspect(label: "sol:5934")

AOC6.input("./6.input")
|> AOC6.solve_first(80)
|> IO.inspect(label: "sol:377263")

AOC6.input("./6.test.input")
|> AOC6.solve_first(256)
|> IO.inspect(label: "sol:26984457539")

AOC6.input("./6.input")
|> AOC6.solve_first(256)
|> IO.inspect(label: "sol:1695929023803")
