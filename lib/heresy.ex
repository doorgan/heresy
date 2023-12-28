defmodule Heresy do
  @doc """
  Combine expressions with escape hatches.

  `begin/1` is similar to `with`, except that it allows you to escape the
  block early upon pattern match failes by using `match`.

  ## Examples

      iex> begin do
      ...>  match true = String.valid?("foo")
      ...>  String.upcase("foo")
      ...> end
      "FOO"

      iex> begin do
      ...>  match true = String.valid?(<<128>>)
      ...>  String.upcase("foo")
      ...> end
      false

      iex> begin do
      ...>  match true = String.valid?(<<128>>), else: {:error, :invalid_string}
      ...>  String.upcase("foo")
      ...> end
      {:error, :invalid_string}
  """
  defmacro begin(blocks) do
    do_content =
      case blocks[:do] do
        {:__block__, _, content} -> content
        content -> [content]
      end

    {last, exprs} = List.pop_at(do_content, -1)

    exprs =
      Enum.map(exprs, &process_match/1)

    last = process_match(last, true)

    other_blocks = Keyword.delete(blocks, :do)

    quote generated: true do
      with(unquote_splicing(exprs), unquote(other_blocks ++ [do: last]))
    end
  end

  defp process_match(quoted, last? \\ false)

  defp process_match({:match, _, [{:=, _, [pattern, expr]} = child | opts]}, last?) do
    opts = List.flatten(opts)

    if opts[:else] do
      cased =
        quote generated: true do
          result = unquote(expr)

          if match?(unquote(pattern), result) do
            result
          else
            unquote(opts[:else])
          end
        end

      if last? do
        cased
      else
        quote generated: true do
          unquote(pattern) <- unquote(cased)
        end
      end
    else
      if last? do
        child
      else
        quote generated: true do
          unquote(pattern) <- unquote(expr)
        end
      end
    end
  end

  defp process_match(other, _last?), do: other
end
