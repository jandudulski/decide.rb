# frozen_string_literal: true

require "test_helper"

class TestDecider < Minitest::Spec
  State = Data.define(:value)
  Increase = Data.define(:value)
  Decrease = Data.define(:value)
  ValueChanged = Data.define(:value)
  ValueIncreased = Data.define(:value)
  ValueDecreased = Data.define(:value)

  describe ".initial_state" do
    it "raises if initial state not defined" do
      assert_raises(Decider::StateNotDefined) do
        Decider.define
      end
    end

    it "raises if initial state already defined" do
      assert_raises(Decider::StateAlreadyDefined) do
        Decider.define do
          initial_state State.new(value: 1)
          initial_state State.new(value: 2)
        end
      end
    end

    it "stores initial state" do
      decider = Decider.define do
        initial_state State.new(value: "value")
      end

      assert_equal decider.initial_state, State.new(value: "value")
    end
  end

  describe "#decide" do
    it "returns empty list when command not defined" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide Increase do |_command, _state|
          []
        end
      end

      assert_equal(
        [],
        decider.decide(Decrease.new(value: 2), decider.initial_state)
      )
    end

    it "executes a defined command" do
      decider = Decider.define do
        initial_state State.new(value: 5)

        decide Increase do |command, state|
          [
            ValueChanged.new(value: state.value + command.value)
          ]
        end

        decide Decrease do |command, state|
          [
            ValueChanged.new(value: state.value - command.value)
          ]
        end
      end

      assert_equal(
        [ValueChanged.new(value: 7)],
        decider.decide(Increase.new(value: 2), decider.initial_state)
      )

      assert_equal(
        [ValueChanged.new(value: 3)],
        decider.decide(Decrease.new(value: 2), decider.initial_state)
      )
    end
  end

  describe "#decide!" do
    it "raises when command not defined" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide Increase do |_command, _state|
          []
        end
      end

      assert_raises(ArgumentError, "Unknown command: TestDecider::Increase") do
        decider.decide!(Decrease.new(value: 2), decider.initial_state)
      end
    end
  end

  describe "#evolve" do
    it "returns state when event not defined" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        evolve ValueIncreased do |state, event|
          state.with(value: state.value + event.value)
        end
      end

      state = decider.initial_state

      assert_equal(
        state,
        decider.evolve(state, ValueDecreased.new(value: 2))
      )
    end

    it "evolves a defined event" do
      decider = Decider.define do
        initial_state State.new(value: 5)

        evolve ValueIncreased do |state, event|
          state.with(value: state.value + event.value)
        end

        evolve ValueDecreased do |state, event|
          state.with(value: state.value - event.value)
        end
      end

      assert_equal(
        State.new(value: 7),
        decider.evolve(decider.initial_state, ValueIncreased.new(value: 2))
      )

      assert_equal(
        State.new(value: 3),
        decider.evolve(decider.initial_state, ValueDecreased.new(value: 2))
      )
    end
  end

  describe "#evolve!" do
    it "raises when event not defined" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        evolve ValueIncreased do |state, event|
          state.with(value: state.value + event.value)
        end
      end

      assert_raises(ArgumentError, "Unknown event: TestDecider::ValueDecreased") do
        decider.evolve!(decider.initial_state, ValueDecreased.new(value: 2))
      end
    end
  end

  describe "#terminal?" do
    it "returns false when not defined" do
      decider = Decider.define do
        initial_state State.new(value: 0)
      end

      refute(
        decider.terminal?(decider.initial_state)
      )
    end

    it "returns true for terminated state" do
      decider = Decider.define do
        initial_state State.new(value: 100)

        terminal? do |state|
          state.value <= 0
        end
      end

      refute(
        decider.terminal?(decider.initial_state)
      )

      assert(
        decider.terminal?(State.new(value: 0))
      )
    end
  end
end
