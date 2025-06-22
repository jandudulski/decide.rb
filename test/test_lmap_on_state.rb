# frozen_string_literal: true

require "test_helper"

class TestLmapOnState < Minitest::Test
  State = Data.define(:value)

  describe ".lmap_on_state" do
    it "does not impact initial state" do
      decider = Decider.define do
        initial_state State.new(value: 0)
      end

      decider = Decider.lmap_on_state(->(state) {}, decider)

      assert_equal(State.new(value: 0), decider.initial_state)
    end

    it "maps on decide" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide :increase, State do
          emit :increased
        end
      end

      decider = Decider.lmap_on_state(
        ->(state) { State.new(value: state[:value]) }, decider
      )

      assert_equal([:increased], decider.decide(:increase, {value: 0}))
    end

    it "maps on evolve" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        evolve State, :increased do
          state.with(value: state.value + 1)
        end
      end

      decider = Decider.lmap_on_state(
        ->(state) { State.new(value: state[:value]) }, decider
      )

      assert_equal(State.new(value: 1), decider.evolve({value: 0}, :increased))
    end

    it "maps on terminal?" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        terminal? do
          state.value == 1
        end
      end

      decider = Decider.lmap_on_state(
        ->(state) { State.new(value: state[:value]) }, decider
      )

      assert_equal(false, decider.terminal?({value: 0}))
      assert_equal(true, decider.terminal?({value: 1}))
    end
  end

  describe "#lmap_on_state" do
    it "does not impact initial state" do
      decider = Decider.define do
        initial_state State.new(value: 0)
      end

      decider = decider.lmap_on_state(->(state) {})

      assert_equal(State.new(value: 0), decider.initial_state)
    end

    it "maps on decide" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide :increase, State do
          emit :increased
        end
      end

      decider = decider.lmap_on_state(
        ->(state) { State.new(value: state[:value]) }
      )

      assert_equal([:increased], decider.decide(:increase, {value: 0}))
    end

    it "maps on evolve" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        evolve State, :increased do
          state.with(value: state.value + 1)
        end
      end

      decider = decider.lmap_on_state(
        ->(state) { State.new(value: state[:value]) }
      )

      assert_equal(State.new(value: 1), decider.evolve({value: 0}, :increased))
    end

    it "maps on terminal?" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        terminal? do
          state.value == 1
        end
      end

      decider = decider.lmap_on_state(
        ->(state) { State.new(value: state[:value]) }
      )

      assert_equal(false, decider.terminal?({value: 0}))
      assert_equal(true, decider.terminal?({value: 1}))
    end
  end
end
