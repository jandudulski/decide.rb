# frozen_string_literal: true

require "test_helper"

class TestEvolve < Minitest::Spec
  State = Data.define(:value)
  Increased = Data.define(:value)
  Decreased = Data.define(:value)

  describe "#evolve" do
    it "returns state when event not defined" do
      decider = Decider.define do
        initial_state 0

        evolve Increased do |state, event|
          state.with(value: state.value + event.value)
        end
      end

      state = decider.initial_state

      assert_equal(
        state,
        decider.evolve(state, Decreased.new(value: 1))
      )
    end

    it "evolves with a defined event" do
      decider = Decider.define do
        initial_state State.new(value: 5)

        evolve Increased do |state, event|
          state.with(value: state.value + event.value)
        end

        evolve Decreased do |state, event|
          state.with(value: state.value - event.value)
        end
      end

      assert_equal(
        State.new(value: 7),
        decider.evolve(decider.initial_state, Increased.new(value: 2))
      )

      assert_equal(
        State.new(value: 3),
        decider.evolve(decider.initial_state, Decreased.new(value: 2))
      )
    end

    it "can evolve with primitives" do
      decider = Decider.define do
        initial_state State.new(value: 5)

        evolve :increased do |state, event|
          state.with(value: state.value + 1)
        end

        evolve :decreased do |state, event|
          state.with(value: state.value - 1)
        end
      end

      assert_equal(
        State.new(value: 6),
        decider.evolve(decider.initial_state, :increased)
      )

      assert_equal(
        State.new(value: 4),
        decider.evolve(decider.initial_state, :decreased)
      )
    end
  end

  describe "#evolve!" do
    it "can evolve with primitives" do
      decider = Decider.define do
        initial_state State.new(value: 5)

        evolve :increased do |state, event|
          state.with(value: state.value + 1)
        end

        evolve :decreased do |state, event|
          state.with(value: state.value - 1)
        end
      end

      assert_equal(
        State.new(value: 6),
        decider.evolve!(decider.initial_state, :increased)
      )

      assert_equal(
        State.new(value: 4),
        decider.evolve!(decider.initial_state, :decreased)
      )
    end

    it "raises when event not defined" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        evolve Increased do |state, event|
          state.with(value: state.value + event.value)
        end
      end

      assert_raises(ArgumentError, "Unknown event: TestDecider::ValueDecreased") do
        decider.evolve!(decider.initial_state, Decreased.new(value: 2))
      end
    end
  end
end
