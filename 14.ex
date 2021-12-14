defmodule AOC14 do
  def input(file) do
    {:ok, content} = File.read(file)

    [templ, pair_ins] =
      content
      |> String.split("\n\n", trim: true)

    pair_ins
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " -> ", trim: true))
    |> then(&{templ |> String.split("", trim: true), &1})
  end

  def solve({templ, pairs}, steps) do
    gen_freq =
      for _i <- 1..steps, reduce: %{} do
        acc -> next_gen_freq(pairs, acc)
      end

    initial_frequencies = templ |> Enum.frequencies()

    for {a, b} <- running_pairs(templ), reduce: initial_frequencies do
      acc -> Map.merge(gen_freq[a <> b], acc, &sum/3)
    end
    |> count()
  end

  # running_pairs([a, b, c]) => [{a, b}, {b, c}]
  def running_pairs(ls) do
    ls |> Enum.zip(Enum.slice(ls, 1..(length(ls) - 1)))
  end

  def next_gen_freq(pairs, map) do
    for [<<a, b>> = pair, <<ins>>] <- pairs, reduce: %{} do
      freqs ->
        (map[<<a, ins>>] || %{})
        |> Map.merge(map[<<ins, b>>] || %{}, &sum/3)
        |> Map.merge(%{<<ins>> => 1}, &sum/3)
        |> then(&Map.merge(freqs, %{pair => &1}))
    end
  end

  def sum(_k, a, b), do: a + b

  def count(freqs) do
    freqs
    |> Enum.to_list()
    |> Enum.min_max_by(&elem(&1, 1))
    |> then(fn {{_min_char, min_count}, {_max_char, max_count}} ->
      max_count - min_count
    end)
  end
end

AOC14.input("14.test.input")
|> AOC14.solve(10)
|> IO.inspect(label: "sol: 1588")

AOC14.input("14.input")
|> AOC14.solve(10)
|> IO.inspect(label: "sol: 3247")

AOC14.input("14.test.input")
|> AOC14.solve(40)
|> IO.inspect(label: "sol: 2188189693529")

AOC14.input("14.input")
|> AOC14.solve(40)
|> IO.inspect(label: "sol: 4110568157153")
