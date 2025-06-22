# frozen_string_literal: true

require "test_helper"

class TestDimapOnEvent < Minitest::Test
  State = Data.define(:value)

  describe ".dimap_on_event" do
    it "does not impact initial state" do
      decider = Decider.define do
        initial_state 0
      end

      decider = Decider.dimap_on_event(
        ->(event) {},
        ->(event) {},
        decider
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

      decider = Decider.dimap_on_event(
        ->(event) {},
        ->(event) {},
        decider
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

      decider = Decider.dimap_on_event(
        ->(event) {},
        ->(event) { event.to_s },
        decider
      )

      assert_equal(["increased"], decider.decide(:increase, 0))
    end

    it "maps on evolve" do
      decider = Decider.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      decider = Decider.dimap_on_event(
        ->(event) { event.to_sym },
        ->(event) {},
        decider
      )

      assert_equal(1, decider.evolve(0, "increased"))
    end
  end

  describe "#dimap_on_event" do
    it "does not impact initial state" do
      decider = Decider.define do
        initial_state 0
      end

      decider = decider.dimap_on_event(
        fl: ->(event) {},
        fr: ->(event) {}
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

      decider = decider.dimap_on_event(
        fl: ->(event) {},
        fr: ->(event) {}
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

      decider = decider.dimap_on_event(
        fl: ->(event) {},
        fr: ->(event) { event.to_s }
      )

      assert_equal(["increased"], decider.decide(:increase, 0))
    end

    it "maps on evolve" do
      decider = Decider.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      decider = decider.dimap_on_event(
        fl: ->(event) { event.to_sym },
        fr: ->(event) {}
      )

      assert_equal(1, decider.evolve(0, "increased"))
    end
  end
end
