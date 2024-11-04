# frozen_string_literal: true

require "test_helper"

class TestCompose < Minitest::Spec
  describe "initial_state" do
    it "composes initial states" do
      left = Decider.define do
        state key: "left"
      end

      right = Decider.define do
        state key: "right"
      end

      composition = Decider.compose(left, right)

      assert_equal(
        composition.new(
          left: left.initial_state,
          right: right.initial_state
        ),
        composition.initial_state
      )
    end
  end

  describe "terminal?" do
    it "returns false when none are terminated" do
      left = Decider.define do
        state terminated?: false

        terminal? do |state|
          state.terminated?
        end
      end

      right = Decider.define do
        state terminated?: false

        terminal? do |state|
          state.terminated?
        end
      end

      composition = Decider.compose(left, right)

      refute composition.terminal?(composition.initial_state)
    end

    it "returns false when left is terminated" do
      left = Decider.define do
        state terminated?: true

        terminal? do |state|
          state.terminated?
        end
      end

      right = Decider.define do
        state terminated?: false

        terminal? do |state|
          state.terminated?
        end
      end

      composition = Decider.compose(left, right)

      refute composition.terminal?(composition.initial_state)
    end

    it "returns false when right is terminated" do
      left = Decider.define do
        state terminated?: false

        terminal? do |state|
          state.terminated?
        end
      end

      right = Decider.define do
        state terminated?: true

        terminal? do |state|
          state.terminated?
        end
      end

      composition = Decider.compose(left, right)

      refute composition.terminal?(composition.initial_state)
    end

    it "returns true when both are terminated" do
      left = Decider.define do
        state terminated?: true

        terminal? do |state|
          state.terminated?
        end
      end

      right = Decider.define do
        state terminated?: true

        terminal? do |state|
          state.terminated?
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
        state key: 0

        decide(lcommand) do |command, state|
          [levent.new(value: command.value)]
        end
      end

      rcommand = Data.define(:value)
      revent = Data.define(:value)

      right = Decider.define do
        state key: 0

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

  describe "evolve" do
    it "composes evolutions" do
      levent = Data.define(:value)

      left = Decider.define do
        state value: 0

        evolve(levent) do |state, event|
          state.with(value: state.value + event.value)
        end
      end

      revent = Data.define(:value)

      right = Decider.define do
        state value: 0

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
        composition.new(
          left: left.new(value: 1),
          right: right.new(value: 2)
        ),
        state
      )
    end
  end
end
