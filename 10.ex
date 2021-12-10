defmodule AOC10 do
  @openings '([{<'
  @closings ')]}>'

  defguard matching?(e, v) when [e, v] in ['()', '[]', '{}', '<>']

  def input(file) do
    {:ok, content} = File.read(file)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  def solve_first(input) do
    input
    |> Enum.map(&find_illegal/1)
    |> Enum.filter(&(!is_list(&1)))
    |> Enum.map(&points/1)
    |> Enum.sum()
  end

  def solve_second(input) do
    input
    |> Enum.map(&find_illegal/1)
    |> Enum.filter(&is_list/1)
    |> Enum.map(&calc_score/1)
    |> Enum.sort()
    |> then(fn ls -> Enum.at(ls, ls |> length() |> div(2)) end)
  end

  def points(?\)), do: 3
  def points(?\]), do: 57
  def points(?\}), do: 1197
  def points(?>), do: 25137

  def cpoints(?\(), do: 1
  def cpoints(?\[), do: 2
  def cpoints(?\{), do: 3
  def cpoints(?<), do: 4

  def find_illegal(line) do
    line
    |> Enum.reduce_while([], fn
      e, ls when e in @openings ->
        {:cont, [e | ls]}

      e, [h | t] when e in @closings and matching?(h, e) ->
        {:cont, t}

      e, _ls ->
        {:halt, e}
    end)
  end

  def calc_score(line) do
    line
    |> Enum.map(&cpoints/1)
    |> Enum.reduce(0, &(&2 * 5 + &1))
  end
end

AOC10.input("./10.test.input")
|> AOC10.solve_first()
|> IO.inspect(label: "sol: 26397")

AOC10.input("./10.input")
|> AOC10.solve_first()
|> IO.inspect(label: "sol: 394647")

AOC10.input("./10.test.input")
|> AOC10.solve_second()
|> IO.inspect(label: "sol: 288957")

AOC10.input("./10.input")
|> AOC10.solve_second()
|> IO.inspect(label: "sol: 288957")
