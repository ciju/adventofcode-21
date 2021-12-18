defmodule AOC18 do
  def solve_first(input) do
    Enum.reduce(input, fn num, sum ->
      add(sum, num)
    end)
    |> maginitude()
  end

  def solve_second(input) do
    max_idx = length(input) - 1

    for i <- 0..max_idx, j <- 0..max_idx, i != j do
      [i, j]
    end
    |> Enum.map(fn [i, j] -> [Enum.at(input, i), Enum.at(input, j)] end)
    |> Enum.map(&solve_first/1)
    |> Enum.max()
  end

  def maginitude(n) when is_number(n), do: n
  def maginitude([l, r]), do: 3 * maginitude(l) + 2 * maginitude(r)

  def add(a, b) do
    Stream.iterate(:loop, fn _ -> :loop end)
    |> Enum.reduce_while([a, b], fn :loop, acc ->
      case red(acc) do
        %{do: :adj, num: num} ->
          {:cont, num}

        %{do: :act, num: num} ->
          case red_split(num) do
            {true, split} ->
              {:cont, split}

            {false, split} ->
              {:halt, split}
          end
      end
    end)
  end

  def rec(ls) do
    %{num: num} = red(ls)
    num
  end

  def spl(ls), do: red_split(ls)

  def red_split(n) when is_number(n) and n > 9, do: {true, [floor(n / 2), ceil(n / 2)]}
  def red_split(n) when is_number(n), do: {false, n}

  def red_split([l, r]) do
    {l_split?, l_ls} = red_split(l)

    if l_split? do
      {true, [l_ls, r]}
    else
      {r_split?, r_ls} = red_split(r)
      {r_split?, [l, r_ls]}
    end
  end

  def red(state, depth \\ 0)
  def red(state, depth) when is_list(state), do: red(%{do: :act, num: state, ar: 0, al: 0})

  def red(%{do: :adj, ar: ar, al: al, num: num} = state, _depth)
      when is_number(num) and (ar > 0 or al > 0) do
    if ar != 0 and al != 0, do: throw(:residue_cant_be_from_both_sides)

    %{state | num: num + ar + al, ar: 0, al: 0}
  end

  def red(%{num: num} = state, _depth) when is_number(num) do
    state
  end

  def adjust_to(:left, num, v) when is_integer(num), do: num + v
  def adjust_to(:left, [a, b], v), do: [adjust_to(:left, a, v), b]
  def adjust_to(:right, num, v) when is_integer(num), do: num + v
  def adjust_to(:right, [a, b], v), do: [a, adjust_to(:right, b, v)]

  # explode
  def red(%{do: :act, num: [a, b]} = state, depth)
      when depth > 3 and is_number(a) and is_number(b) do
    %{state | num: 0, al: a, ar: b, do: :adj}
  end

  def red(%{do: :adj, num: num, ar: ar} = state, depth)
      when ar != 0 do
    %{state | num: adjust_to(:left, num, ar), ar: 0}
  end

  def red(%{do: :adj, num: num, al: al} = state, depth)
      when al != 0 do
    %{state | num: adjust_to(:right, num, al), al: 0}
  end

  def red(%{do: :adj, num: [a, b], ar: 0, al: 0} = state, _depth) do
    state
  end

  def red(%{do: :act, num: [a, b]} = state, depth) do
    a = red(%{state | num: a}, depth + 1)

    case a.do do
      :act ->
        b = red(%{do: :act, num: b, al: 0, ar: 0}, depth + 1)

        case b.do do
          :act ->
            %{do: :act, num: [a.num, b.num], al: 0, ar: 0}

          :adj ->
            num = adjust_to(:right, a.num, b.al)
            %{do: :adj, num: [num, b.num], al: 0, ar: b.ar}
        end

      :adj ->
        num = adjust_to(:left, b, a.ar)
        %{do: :adj, num: [a.num, num], al: a.al, ar: 0}
    end
    |> then(fn state ->
      if depth == 0, do: state, else: state
    end)
  end
end

# AOC18.solve_first(AOC18.Input.sample_4())
# |> IO.inspect(label: "sol: 3488")

# AOC18.solve_first(AOC18.Input.sample_5())
# |> IO.inspect(label: "sol: 4140")

# AOC18.solve_second(AOC18.Input.sample_5())
# |> IO.inspect(label: "sol: 3993")

AOC18.solve_first(AOC18.Input.input())
|> IO.inspect(label: "sol: 3816")

AOC18.solve_second(AOC18.Input.input())
|> IO.inspect(label: "sol: 4819")
