defmodule AOC19 do
  import Enum, only: [at: 2, map: 2, zip: 2, reduce: 3]

  def split(x, s), do: String.split(x, s, trim: true)

  def intersect(l1, l2) do
    l3 = l1 -- l2
    l1 -- l3
  end

  def input(file) do
    {:ok, content} = File.read(file)
    parse(content)
  end

  def parse(content) do
    scanners =
      content
      |> split("--- scanner ---")

    for str <- scanners do
      for line <- split(str, "\n") do
        for n <- split(line, ",") do
          String.to_integer(n)
        end
      end
    end
  end

  def solve(scanners) do
    {dists, beacons} =
      at(scanners, 0)
      |> merge_scanner({[], Enum.slice(scanners, 1..(length(scanners) - 1))})

    manhatten = manhatten_distances(dists) |> Enum.max()

    beacons
    |> Enum.sort()
    |> Enum.uniq()
    |> length()
    |> then(&{&1, manhatten})
  end

  def manhatten_distances(points) do
    for x <- points, y <- points, x != y do
      sub(x, y)
      |> Enum.map(&abs/1)
      |> Enum.sum()
    end
  end

  def merge_scanner(a, {dists, []}), do: {dists, a}

  def merge_scanner(a, {dists, scanners}) do
    i = Enum.find_index(scanners, &common_points(a, &1))

    {dist, a} = collect_beacons(a, at(scanners, i))
    merge_scanner(a, {[dist | dists], List.delete_at(scanners, i)})
  end

  def collect_beacons(scan_a, scan_b) do
    point_pairs = common_points(scan_a, scan_b)

    if point_pairs do
      point_map =
        point_pairs
        |> gen_line_map()
        |> gen_point_map()

      rotation_map =
        point_map
        |> relative_coordinates()
        |> find_rotation()

      {a, b} = Enum.random(point_map)

      displacement = sub(a, map_point(rotation_map, b))

      b_adjusted =
        Enum.map(scan_b, fn p ->
          map_point(rotation_map, p)
          |> then(&add(&1, displacement))
        end)

      (scan_a ++ b_adjusted)
      |> Enum.uniq()
      |> then(&{displacement, &1})
    end
  end

  def common_points(scan_a, scan_b) do
    a_sigs = line_sigs(scan_a)
    b_sigs = line_sigs(scan_b)

    common_sigs =
      a_sigs
      |> Map.keys()
      |> intersect(b_sigs |> Map.keys())

    if length(common_sigs) >= 3 do
      common_sigs
      |> map(&{a_sigs[&1], b_sigs[&1]})
    end
  end

  def gen_line_map(common_sigs) do
    common_sigs
    |> Enum.reduce(%{}, fn {{a1, a2}, _b} = line_map, acc ->
      Map.update(acc, a1, [line_map], &[line_map | &1])
      |> Map.update(a2, [line_map], &[line_map | &1])
    end)
  end

  def find_rotation(rel_point_map) do
    # find point with unique axis values and derive rotation from corresponding
    # map
    {a, b} =
      rel_point_map
      |> Enum.find(fn {a, _b} ->
        Enum.uniq(a) |> Enum.count() == 3
      end)

    b
    |> Enum.with_index()
    |> map(fn {x, _i} ->
      j = Enum.find_index(a, &(abs(&1) == abs(x)))

      {j, div(at(a, j), x)}
    end)
  end

  def map_point(map_index, point) do
    point
    |> Enum.zip(map_index)
    |> map(fn {v, {i, m}} -> {i, v * m} end)
    |> Enum.sort()
    |> map(&elem(&1, 1))
  end

  def relative_coordinates(point_map) do
    {a_base, b_base} = Enum.random(point_map)

    Enum.map(point_map, fn {a, b} ->
      {sub(a, a_base), sub(b, b_base)}
    end)
    |> Enum.into(%{})
  end

  def gen_point_map(line_map) do
    Map.map(line_map, fn
      {_k, [{_a1, {p1, p2}} | [{_a2, {p3, p4}} | _rest]]} ->
        intersect([p1, p2], [p3, p4])
        |> at(0)

      {_k, [{_a1, {_p1, _p2}}]} ->
        nil
    end)
    |> Enum.filter(fn {_, v} -> v end)
  end

  def line_sigs(lines) do
    max = length(lines) - 1

    for i <- 0..(max - 1), j <- (i + 1)..max do
      v1 = at(lines, i)
      v2 = at(lines, j)
      {line_sig(v1, v2), {v1, v2}}
    end
    |> Enum.into(%{})
  end

  def line_sig(p1, p2) do
    zip(p1, p2)
    |> map(fn {a, b} -> abs(a - b) end)
    |> reduce(0, fn x, acc ->
      acc + x * x
    end)
  end

  def sub(p1, p2) do
    zip(p1, p2)
    |> map(fn {a, b} -> a - b end)
  end

  def add(p1, p2) do
    zip(p1, p2)
    |> map(fn {a, b} -> a + b end)
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

AOC19.input("19.test.input")
|> AOC19.solve()
|> IO.inspect(label: "sol: {79, 3621}")

Benchmark.measure(fn ->
  AOC19.input("19.input")
  |> AOC19.solve()
  |> IO.inspect(label: "sol: {318, 12166}")
end)
|> IO.inspect(label: "time")
