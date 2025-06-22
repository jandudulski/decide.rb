# frozen_string_literal: true

require "test_helper"

class TestRmapOnState < Minitest::Test
  State = Data.define(:value)

  describe ".rmap_on_state" do
    it "maps initial state" do
      decider = Decider.define do
        initial_state State.new(value: 0)
      end

      decider = Decider.rmap_on_state(
        ->(state) { {value: state.value} }, decider
      )

      assert_equal({value: 0}, decider.initial_state)
    end

    it "does not impact decide" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide :increase, State do
          emit :increased
        end
      end

      decider = Decider.rmap_on_state(
        ->(state) { {value: state.value} }, decider
      )

      assert_equal([:increased], decider.decide(:increase, State.new(value: 0)))
    end

    it "maps on evolve" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        evolve State, :increased do
          state.with(value: state.value + 1)
        end
      end

      decider = Decider.rmap_on_state(
        ->(state) { {value: state.value} }, decider
      )

      assert_equal({value: 1}, decider.evolve(State.new(value: 0), :increased))
    end

    it "does not impact terminal?" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        terminal? do
          state.value == 1
        end
      end

      decider = Decider.rmap_on_state(
        ->(state) {}, decider
      )

      assert_equal(false, decider.terminal?(State.new(value: 0)))
      assert_equal(true, decider.terminal?(State.new(value: 1)))
    end
  end

  describe "#rmap_on_state" do
    it "maps initial state" do
      decider = Decider.define do
        initial_state State.new(value: 0)
      end

      decider = decider.rmap_on_state(->(state) { {value: state.value} })

      assert_equal({value: 0}, decider.initial_state)
    end

    it "does not impact decide" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide :increase, State do
          emit :increased
        end
      end

      decider = decider.rmap_on_state(->(state) {})

      assert_equal([:increased], decider.decide(:increase, State.new(value: 0)))
    end

    it "maps on evolve" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        evolve State, :increased do
          state.with(value: state.value + 1)
        end
      end

      decider = decider.rmap_on_state(->(state) { {value: state.value} })

      assert_equal({value: 1}, decider.evolve(State.new(value: 0), :increased))
    end

    it "does not impact terminal?" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        terminal? do
          state.value == 1
        end
      end

      decider = decider.rmap_on_state(->(state) {})

      assert_equal(false, decider.terminal?(State.new(value: 0)))
      assert_equal(true, decider.terminal?(State.new(value: 1)))
    end
  end
end
