# frozen_string_literal: true

require "test_helper"

class TestDecider < Minitest::Spec
  Increase = Data.define(:value)
  Decrease = Data.define(:value)
  ValueChanged = Data.define(:value)
  ValueIncreased = Data.define(:value)
  ValueDecreased = Data.define(:value)

  describe ".define" do
    it "raises if state not defined" do
      assert_raises(Decider::StateNotDefined) do
        Decider.define
      end
    end

    it "raises if state already defined" do
      assert_raises(Decider::StateAlreadyDefined) do
        Decider.define do
          state value: 1
          state value: 2
        end
      end
    end
  end

  describe "state" do
    it "creates a state data structure and initial state" do
      decider = Decider.define do
        state key: "value"
      end

      assert_equal decider.initial_state, decider.new(key: "value")
    end

    it "creates a state with custom methods" do
      decider = Decider.define do
        state enabled: true do
          def enabled?
            enabled
          end
        end
      end

      assert decider.initial_state.enabled?
    end
  end

  describe "decide" do
    it "raises when command not defined" do
      decider = Decider.define do
        state init: 0

        decide Increase do |_command, _state|
          []
        end
      end

      assert_raises(ArgumentError, "Unknown command: TestDecider::Increase") do
        decider.decide(Decrease.new(value: 2), decider.initial_state)
      end
    end

    it "executes a defined command" do
      decider = Decider.define do
        state value: 5

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

  describe "evolve" do
    it "raises when event not defined" do
      decider = Decider.define do
        state init: 0

        evolve ValueIncreased do |state, event|
          state.with(value: state.value + event.value)
        end
      end

      assert_raises(ArgumentError, "Unknown event: TestDecider::ValueDecreased") do
        decider.evolve(decider.initial_state, ValueDecreased.new(value: 2))
      end
    end

    it "evolves a defined event" do
      decider = Decider.define do
        state value: 5

        evolve ValueIncreased do |state, event|
          state.with(value: state.value + event.value)
        end

        evolve ValueDecreased do |state, event|
          state.with(value: state.value - event.value)
        end
      end

      assert_equal(
        decider.new(value: 7),
        decider.evolve(decider.initial_state, ValueIncreased.new(value: 2))
      )

      assert_equal(
        decider.new(value: 3),
        decider.evolve(decider.initial_state, ValueDecreased.new(value: 2))
      )
    end
  end

  describe "terminal?" do
    it "returns false when not defined" do
      decider = Decider.define do
        state init: 0
      end

      refute(
        decider.terminal?(decider.initial_state)
      )
    end

    it "returns true for terminated state" do
      decider = Decider.define do
        state value: 100

        terminal? do |state|
          state.value <= 0
        end
      end

      refute(
        decider.terminal?(decider.initial_state)
      )

      assert(
        decider.terminal?(decider.new(value: 0))
      )
    end
  end
end
