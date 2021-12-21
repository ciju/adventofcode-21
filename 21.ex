defmodule AOC21 do
  defmodule Part1 do
    def nth_sum(n) do
      n * 9 - 3
    end

    def score_up(n, {pos, score}) do
      pos = rem(pos + nth_sum(n), 10)
      score = if(pos == 0, do: 10, else: pos) + score
      {pos, score}
    end

    def seq(p1_start \\ 4, p2_start \\ 8) do
      Stream.iterate({0, {p1_start, 0}, {p2_start, 0}, {0, 0}}, fn {step, p1, p2, _p2_prev} ->
        {step + 1, score_up(step * 2 + 1, p1), score_up(step * 2 + 2, p2), p2}
      end)
      |> Enum.find(fn {step, {_, p1_score}, {_, p2_score}, _p2_prev} ->
        p1_score >= 1000 or p2_score >= 1000
      end)
      |> then(fn {step, {_, p1_score}, {_, p2_score}, {_, p2_prev_score}} ->
        cond do
          p1_score >= 1000 ->
            ((step - 1) * 2 * 3 + 3) * p2_prev_score

          p2_score >= 1000 ->
            step * 2 * 3 * p1_score

          true ->
            false
        end
      end)
    end
  end

  defmodule Part2 do
    @perm_counts %{3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1}
    @perm_vals [3, 4, 5, 6, 7, 8, 9]
    @max_score 21

    def update_score(n, {pos, score}) do
      pos = rem(pos + n, 10)
      score = if(pos == 0, do: 10, else: pos) + score
      {pos, score}
    end

    def solve_second(p1_pos, p2_pos) do
      quantum(%{p1: {{p1_pos, 0}, 0}, p2: {{p2_pos, 0}, 0}}, :p1, 1)
      |> Enum.max()
    end

    def quantum(%{p1: {p1, wins_p1}, p2: {p2, wins_p2}}, turn, uns) do
      cond do
        elem(p1, 1) >= @max_score ->
          [wins_p1 + uns, wins_p2]

        elem(p2, 1) >= @max_score ->
          [wins_p1, wins_p2 + uns]

        true ->
          for dice_sum <- @perm_vals, reduce: [wins_p1, wins_p2] do
            [wins_p1, wins_p2] ->
              perm_uns = @perm_counts[dice_sum]
              p1 = if turn == :p1, do: update_score(dice_sum, p1), else: p1
              p2 = if turn == :p2, do: update_score(dice_sum, p2), else: p2

              turn = if turn == :p1, do: :p2, else: :p1

              quantum(%{p1: {p1, wins_p1}, p2: {p2, wins_p2}}, turn, uns * perm_uns)
          end
      end
    end
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

AOC21.Part1.seq(4, 8)
|> IO.inspect(label: "sol: 739785")

AOC21.Part1.seq(6, 9)
|> IO.inspect(label: "sol: 925605")

AOC21.Part2.solve_second(4, 8)
|> IO.inspect(label: "second: 444356092776315")

Benchmark.measure(fn ->
  AOC21.Part2.solve_second(6, 9)
  |> IO.inspect(label: "second: 486638407378784")
end)
|> IO.inspect(label: "time")

# around 12 seconds
