# frozen_string_literal: true

require "test_helper"

class TestMap2 < Minitest::Test
  describe ".map2" do
    it "maps initial state" do
      dx = Decider.define do
        initial_state({x: 0})
      end

      dy = Decider.define do
        initial_state({y: 1})
      end

      decider = Decider.map2(
        ->(sx, sy) { sx.merge(sy) }, dx, dy
      )

      assert_equal({x: 0, y: 1}, decider.initial_state)
    end

    it "concatenates emitted events" do
      dx = Decider.define do
        initial_state({x: 0})

        decide proc { [command, state] in [:command, {x: 0}] } do
          emit :x
        end
      end

      dy = Decider.define do
        initial_state({y: 1})

        decide proc { [command, state] in [:command, {y: 1}] } do
          emit :y
        end
      end

      decider = Decider.map2(
        ->(sx, sy) { sx.merge(sy) }, dx, dy
      )

      assert_equal([:x, :y], decider.decide(:command, {x: 0, y: 1}))
    end

    it "maps evolve from both deciders" do
      dx = Decider.define do
        initial_state({x: 0})

        evolve :event do
          {x: state[:x] + 1}
        end
      end

      dy = Decider.define do
        initial_state({y: 1})

        evolve :event do
          {y: state[:y] + 2}
        end
      end

      decider = Decider.map2(
        ->(sx, sy) { sx.merge(sy) }, dx, dy
      )

      assert_equal(
        {x: 1, y: 3}, decider.evolve({x: 0, y: 1}, :event)
      )
    end

    it "maps on terminal?" do
      dx = Decider.define do
        initial_state({x: 0})

        terminal? do
          state[:x] == 1
        end
      end

      dy = Decider.define do
        initial_state({y: 1})

        terminal? do
          state[:y] == 2
        end
      end

      decider = Decider.map2(
        ->(sx, sy) { sx.merge(sy) }, dx, dy
      )

      refute(decider.terminal?({x: 0, y: 1}))
      refute(decider.terminal?({x: 1, y: 1}))
      refute(decider.terminal?({x: 0, y: 2}))
      assert(decider.terminal?({x: 1, y: 2}))
    end
  end
end
