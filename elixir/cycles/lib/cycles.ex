defmodule Cycles do
  @moduledoc """
  Documentation for Cycles.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Cycles.hello
      :world

  """

  def count_cycles_at(start, stop, set, graph) do
    c = cond do
      stop == start -> 1
      stop > start and not MapSet.member?(set, stop) -> count_cycles_from(start, stop, MapSet.put(set, stop), graph)
      true -> 0
    end
    c
  end

  def count_cycles_from(start, stop, set, graph) do
    Enum.reduce(Map.get(graph, stop, []), 0, fn v, a -> a + count_cycles_at(start, v, set, graph) end)
  end

  def count_cycles(graph) do
    Enum.reduce(Map.keys(graph), 0, fn v, a -> a + count_cycles_from(v, v, MapSet.new, graph) end)
  end

  def head_tuple(line) do
    ids = Enum.map(String.split(line), fn x  -> elem(Integer.parse(x), 0) end)
   {hd(ids), tl ids}
  end

  def read_graph(path) do
    {:ok, data} = File.read path
    lines = String.split(data, "\n")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(fn s -> String.length(s) > 0 && String.first(s) != "#" end)
    Map.new(Enum.map(lines, &head_tuple/1))
  end

  def main(size) do
    start = :os.system_time(:millisecond)
    graph = read_graph "../../data/graph#{size}.adj"
    cycles = count_cycles graph
    stop = :os.system_time(:millisecond)
    IO.puts "Found #{cycles} cycles in #{stop - start} ms"
  end
end

Cycles.main("35")
