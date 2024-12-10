# frozen_string_literal: true

require "test_helper"

class TestTerminal < Minitest::Test
  describe "#terminal?" do
    it "returns false by default" do
      decider = Decider.define do
        initial_state :working
      end

      refute decider.terminal?(:broken)
    end

    it "returns false when not terminated" do
      decider = Decider.define do
        initial_state :working

        terminal? do
          state == :broken
        end
      end

      refute decider.terminal?(:working)
    end

    it "returns true when terminated" do
      decider = Decider.define do
        initial_state :working

        terminal? do
          state == :broken
        end
      end

      assert decider.terminal?(:broken)
    end

    it "returns false when composition not terminated" do
      left = Decider.define do
        initial_state :working

        terminal? do
          state == :broken
        end
      end

      right = Decider.define do
        initial_state :working

        terminal? do
          state == :broken
        end
      end

      composition = Decider.compose(left, right)

      refute composition.terminal?(
        composition.initial_state
      )

      refute composition.terminal?(
        Decider::Pair.new(
          left: left.initial_state,
          right: :broken
        )
      )

      refute composition.terminal?(
        Decider::Pair.new(
          left: :broken,
          right: right.initial_state
        )
      )
    end

    it "returns true when composition is terminated" do
      left = Decider.define do
        initial_state :working

        terminal? do
          state == :broken
        end
      end

      right = Decider.define do
        initial_state :working

        terminal? do
          state == :broken
        end
      end

      composition = Decider.compose(left, right)

      assert composition.terminal?(
        Decider::Pair.new(
          left: :broken,
          right: :broken
        )
      )
    end
  end
end
