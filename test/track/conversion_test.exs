defmodule Track.ConversionTest do
  use ExUnit.Case, async: true

  describe "format_minutes" do
    test "formats time spent in minutes" do
      assert Track.Time.format_minutes(60) == "01:00"
      assert Track.Time.format_minutes(90) == "01:30"
      assert Track.Time.format_minutes(120) == "02:00"
    end
  end

  describe "time_to_minutes" do
    test "converts time spent in minutes" do
      assert Track.Time.time_to_minutes("2") == 120
      assert Track.Time.time_to_minutes("8.5") == 510
      assert Track.Time.time_to_minutes("15") == 15
      assert Track.Time.time_to_minutes("150") == 150
    end

    test "converts time spent in hours and minutes" do
      assert Track.Time.time_to_minutes("01:30") == 90
      assert Track.Time.time_to_minutes("02:45") == 165
    end
  end
end
