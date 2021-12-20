defmodule AOC20 do
  import Enum

  def input(file) do
    {:ok, content} = File.read(file)

    [algo, img] = split_str(content, "\n\n")

    img =
      for {row, ri} <- split_str(img, "\n") |> with_index(),
          {col, ci} <- split_str(row) |> with_index(),
          into: %{} do
        {{ri, ci}, col}
      end

    algo
    |> split_str()
    |> then(&%{algo: &1, img: img, max: img |> Map.keys() |> max(), bg: "."})
  end

  def solve(file, count) do
    for _i <- 0..(count - 1), reduce: input(file) do
      state -> enhance(state)
    end
    |> count_lit
  end

  def enhance(state) do
    %{algo: algo, max: {rmax, cmax}} = state = expand(state)

    new_bg = at(algo, get_algo_index(state, {-10, -10}))

    for r <- 0..rmax do
      for c <- 0..cmax do
        idx = get_algo_index(state, {r, c})
        {{r, c}, at(algo, idx)}
      end
    end
    |> flat_map(& &1)
    |> into(%{})
    |> then(&%{state | img: &1, bg: new_bg})
  end

  def expand(%{img: img, max: {rmax, cmax}} = state) do
    img =
      map(img, fn {{r, c}, val} -> {{r + 1, c + 1}, val} end)
      |> into(%{})

    %{state | img: img, max: {rmax + 2, cmax + 2}}
  end

  def get_algo_index(%{img: img, bg: bg}, {r, c}) do
    [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 0}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
    |> map(fn {rr, cc} -> img[{r + rr, c + cc}] || bg end)
    |> map(&if &1 == "#", do: 1, else: 0)
    |> Enum.join("")
    |> Integer.parse(2)
    |> elem(0)
  end

  def count_lit(%{bg: "#"}), do: :infinity

  def count_lit(%{img: img}) do
    for {_k, v} <- img, reduce: 0 do
      acc -> if v == "#", do: acc + 1, else: acc
    end
  end

  def render_row(%{img: img, max: {_rmax, cmax}} = state, row) do
    for c <- 0..cmax do
      img[{row, c}] || "."
    end
    |> join("")
    |> then(&IO.puts("row #{row}: " <> &1))

    state
  end

  def render(%{img: img, max: {rmax, cmax}} = state) do
    IO.puts("\n")

    for r <- 0..rmax do
      for c <- 0..cmax do
        img[{r, c}]
      end
      |> join("")
    end
    |> join("\n")
    |> IO.puts()

    state
  end

  def split_str(str, sep \\ "") do
    String.split(str, sep, trim: true)
  end
end

defmodule Benchmark do
  def measure(function) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end

AOC20.solve("20.test.input", 2)
|> IO.inspect(label: "count: 35")

AOC20.solve("20.input", 2)
|> IO.inspect(label: "count: 5425")

AOC20.solve("20.test.input", 50)
|> IO.inspect(label: "count: 3351")

Benchmark.measure(fn ->
  AOC20.solve("20.input", 50)
  |> IO.inspect(label: "count: 14052")
end)
|> IO.inspect(label: "time")
