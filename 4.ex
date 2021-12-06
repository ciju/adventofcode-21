defmodule AOC4 do
  def input(file) do
    {:ok, lines} = File.read(file)

    [draws | rest] = lines |> String.split("\n\n", trim: true)

    draws = draws |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)

    boards =
      rest
      |> Enum.map(&parse_board/1)

    {draws, boards}
  end

  def parse_board(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_row/1)
  end

  def parse_row(row) do
    row
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solve_first({draws, boards}) do
    create_map(boards)
    |> solve(draws)
    |> then(fn {_acc, bingos, draws} ->
      {Enum.at(bingos, -1), Enum.at(draws, -1)}
    end)
    |> calc_result(boards, draws)
  end

  def solve_second({draws, boards}) do
    create_map(boards)
    |> solve(draws)
    |> then(fn {_acc, [l | _bingos], [d | _draws]} ->
      {l, d}
    end)
    |> calc_result(boards, draws)
  end

  def calc_result({board_idx, draw}, boards, draws) do
    draws =
      draws
      |> Enum.take_while(fn d -> d != draw end)

    boards
    |> Enum.at(board_idx)
    |> List.flatten()
    |> then(fn ls -> ls -- [draw | draws] end)
    |> Enum.sum()
    |> then(&(&1 * draw))
  end

  def solve(board_maps, draws) do
    draws
    |> Enum.reduce_while({%{}, [], []}, fn draw, acc ->
      check_boards_for_draw(board_maps, draw, acc)
      |> case do
        {:halt, acc} -> {:halt, acc}
        acc -> {:cont, acc}
      end
    end)
  end

  def check_boards_for_draw(board_maps, draw, acc) do
    board_maps
    |> Enum.with_index()
    |> Enum.reduce_while(acc, fn {board, idx}, {state, bingos, draws} = acc ->
      if idx in bingos do
        {:cont, acc}
      else
        board
        |> check_board(draw, state[idx] || %{})
        |> case do
          {:bingo, bstate} when length(bingos) == length(board_maps) ->
            acc = {Map.merge(state, %{idx => bstate}), [idx | bingos], [draw | draws]}
            {:halt, {:halt, acc}}

          {:bingo, bstate} ->
            acc = {Map.merge(state, %{idx => bstate}), [idx | bingos], [draw | draws]}
            {:cont, acc}

          {:cont, bstate} ->
            {:cont, {Map.merge(state, %{idx => bstate}), bingos, draws}}
        end
      end
    end)
  end

  def check_board(board_map, draw, acc) do
    if !Map.has_key?(board_map, draw) do
      {:cont, acc}
    else
      {r, c} = Map.get(board_map, draw)
      {_, acc} = Map.get_and_update(acc, {:row, r}, &{&1, (&1 || 0) + 1})
      {_, acc} = Map.get_and_update(acc, {:col, c}, &{&1, (&1 || 0) + 1})

      (acc[{:row, r}] == 5 or acc[{:col, c}] == 5)
      |> case do
        true -> {:bingo, acc}
        _ -> {:cont, acc}
      end
    end
  end

  def create_map(boards) do
    boards
    |> Enum.map(&create_board_map/1)
  end

  def create_board_map(board) do
    board
    |> Enum.with_index()
    |> Enum.map(fn {row, r} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {v, c} ->
        {v, {r, c}}
      end)
      |> Enum.into(%{})
    end)
    |> Enum.reduce(&Map.merge(&1, &2))
  end
end

AOC4.input("./4.test.input")
|> AOC4.solve_first()
|> IO.inspect(label: "should_be:4512")

IO.puts("\n")

AOC4.input("./4.input")
|> AOC4.solve_first()
|> IO.inspect(label: "should_be:11536")

IO.puts("\n")

# [1, 0, 2], [13, 16, 24]
AOC4.input("./4.test.input")
|> AOC4.solve_second()
|> IO.inspect(label: "should_be:1924")

IO.puts("\n")

AOC4.input("./4.input")
|> AOC4.solve_second()
|> IO.inspect(label: "should_be:1284")
