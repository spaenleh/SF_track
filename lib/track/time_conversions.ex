defmodule Track.TimeConversions do
  # "HH:MM" format
  def to_minutes(<<_h1, _h2, ?:, _m1, _m2>> = time) do
    [hours, minutes] = time |> String.split(":") |> Enum.map(&String.to_integer/1)
    hours * 60 + minutes
  end

  # Decimal or integer: ≤10 treated as hours (8.5 → 510), >10 as minutes (150 → 150)
  def to_minutes(value) when is_binary(value) do
    case Float.parse(value) do
      {n, _} when n <= 10 -> floor(n * 60)
      {n, _} -> floor(n)
      :error -> nil
    end
  end

  def format_minutes(time_spent) when is_integer(time_spent) do
    hours = div(time_spent, 60) |> Integer.to_string() |> String.pad_leading(2, "0")
    minutes = rem(time_spent, 60) |> Integer.to_string() |> String.pad_leading(2, "0")

    "#{hours}:#{minutes}"
  end
end
