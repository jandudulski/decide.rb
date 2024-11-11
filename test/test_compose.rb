# frozen_string_literal: true

require "test_helper"

class TestCompose < Minitest::Spec
  Left = Data.define(:value)
  Right = Data.define(:value)

  describe "#initial_state" do
    it "composes initial states" do
      left = Decider.define do
        initial_state Left.new(value: 0)
      end

      right = Decider.define do
        initial_state Right.new(value: 0)
      end

      composition = Decider.compose(left, right)

      assert_equal(
        [left.initial_state, right.initial_state],
        composition.initial_state
      )
    end
  end

  describe "#terminal?" do
    it "returns false when none are terminated" do
      left = Decider.define do
        initial_state Left.new(value: false)

        terminal? do |state|
          state.value
        end
      end

      right = Decider.define do
        initial_state Right.new(value: false)

        terminal? do |state|
          state.value
        end
      end

      composition = Decider.compose(left, right)

      refute composition.terminal?(composition.initial_state)
    end

    it "returns false when left is terminated" do
      left = Decider.define do
        initial_state Left.new(value: true)

        terminal? do |state|
          state.value
        end
      end

      right = Decider.define do
        initial_state Right.new(value: false)

        terminal? do |state|
          state.value
        end
      end

      composition = Decider.compose(left, right)

      refute composition.terminal?(composition.initial_state)
    end

    it "returns false when right is terminated" do
      left = Decider.define do
        initial_state Left.new(value: false)

        terminal? do |state|
          state.value
        end
      end

      right = Decider.define do
        initial_state Right.new(value: true)

        terminal? do |state|
          state.value
        end
      end

      composition = Decider.compose(left, right)

      refute composition.terminal?(composition.initial_state)
    end

    it "returns true when both are terminated" do
      left = Decider.define do
        initial_state Left.new(value: true)

        terminal? do |state|
          state.value
        end
      end

      right = Decider.define do
        initial_state Right.new(value: true)

        terminal? do |state|
          state.value
        end
      end

      composition = Decider.compose(left, right)

      assert composition.terminal?(composition.initial_state)
    end
  end

  describe "decide" do
    it "composes decisions" do
      lcommand = Data.define(:value)
      levent = Data.define(:value)

      left = Decider.define do
        initial_state Left.new(value: 0)

        decide(lcommand) do |command, state|
          [levent.new(value: command.value)]
        end
      end

      rcommand = Data.define(:value)
      revent = Data.define(:value)

      right = Decider.define do
        initial_state Right.new(value: 0)

        decide(rcommand) do |command, state|
          [revent.new(value: command.value)]
        end
      end

      composition = Decider.compose(left, right)

      assert_equal(
        [levent.new(value: 1)],
        composition.decide(lcommand.new(value: 1), composition.initial_state)
      )

      assert_equal(
        [revent.new(value: 1)],
        composition.decide(rcommand.new(value: 1), composition.initial_state)
      )
    end
  end

  describe "#evolve" do
    it "composes evolutions" do
      levent = Data.define(:value)

      left = Decider.define do
        initial_state Left.new(value: 0)

        evolve(levent) do |state, event|
          state.with(value: state.value + event.value)
        end
      end

      revent = Data.define(:value)

      right = Decider.define do
        initial_state Right.new(value: 0)

        evolve(revent) do |state, event|
          state.with(value: state.value + event.value)
        end
      end

      composition = Decider.compose(left, right)

      state = [
        levent.new(value: 1),
        revent.new(value: 2)
      ].reduce(composition.initial_state, &composition.method(:evolve))

      assert_equal(
        [
          Left.new(value: 1),
          Right.new(value: 2)
        ],
        state
      )
    end
  end
end
