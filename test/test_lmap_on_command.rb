# frozen_string_literal: true

require "test_helper"

class TestLmapOnCommand < Minitest::Spec
  describe ".lmap_on_command" do
    it "does not impact initial state" do
      decider = Decider.define do
        initial_state 0
      end

      decider = Decider.lmap_on_command(
        decider, ->(command) {}
      )

      assert_equal(0, decider.initial_state)
    end

    it "does not impact terminal?" do
      decider = Decider.define do
        initial_state 0

        terminal? do
          state == 1
        end
      end

      decider = Decider.lmap_on_command(
        decider, ->(command) {}
      )

      refute decider.terminal?(0)
      assert decider.terminal?(1)
    end

    it "maps on decide" do
      decider = Decider.define do
        initial_state 0

        decide :increase do
          emit :increased
        end
      end

      decider = Decider.lmap_on_command(
        decider, ->(command) { command.to_sym }
      )

      assert_equal([:increased], decider.decide("increase", 0))
    end

    it "does not impact evolve" do
      decider = Decider.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      decider = Decider.lmap_on_command(
        decider, ->(command) {}
      )

      assert_equal(1, decider.evolve(0, :increased))
    end
  end

  describe "#lmap_on_command" do
    it "does not impact initial state" do
      decider = Decider.define do
        initial_state 0
      end

      decider = decider.lmap_on_command(->(command) {})

      assert_equal(0, decider.initial_state)
    end

    it "does not impact terminal?" do
      decider = Decider.define do
        initial_state 0

        terminal? do
          state == 1
        end
      end

      decider = decider.lmap_on_command(->(command) {})

      refute decider.terminal?(0)
      assert decider.terminal?(1)
    end

    it "maps on decide" do
      decider = Decider.define do
        initial_state 0

        decide :increase do
          emit :increased
        end
      end

      decider = decider.lmap_on_command(
        ->(command) { command.to_sym }
      )

      assert_equal([:increased], decider.decide("increase", 0))
    end

    it "does not impact evolve" do
      decider = Decider.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      decider = decider.lmap_on_command(->(command) {})

      assert_equal(1, decider.evolve(0, :increased))
    end
  end
end
