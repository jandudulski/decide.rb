# frozen_string_literal: true

require "test_helper"

class TestDimapOnState < Minitest::Test
  State = Data.define(:value)

  describe ".dimap_on_state" do
    it "maps initial state" do
      decider = Decider.define do
        initial_state State.new(value: 0)
      end

      decider = Decider.dimap_on_state(
        decider,
        fl: ->(state) {},
        fr: ->(state) { {value: state.value} }
      )

      assert_equal({value: 0}, decider.initial_state)
    end

    it "maps on decide" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide :increase, State do
          emit :increased
        end
      end

      decider = Decider.dimap_on_state(
        decider,
        fl: ->(state) { State.new(value: state[:value]) },
        fr: ->(state) { {value: state.value} }
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

      decider = Decider.dimap_on_state(
        decider,
        fl: ->(state) { State.new(value: state[:value]) },
        fr: ->(state) { {value: state.value} }
      )

      assert_equal({value: 1}, decider.evolve({value: 0}, :increased))
    end

    it "maps on terminal?" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        terminal? do
          state.value == 1
        end
      end

      decider = Decider.dimap_on_state(
        decider,
        fl: ->(state) { State.new(value: state[:value]) },
        fr: ->(state) {}
      )

      assert_equal(false, decider.terminal?({value: 0}))
      assert_equal(true, decider.terminal?({value: 1}))
    end
  end

  describe "#dimap_on_state" do
    it "maps initial state" do
      decider = Decider.define do
        initial_state State.new(value: 0)
      end

      decider = decider.dimap_on_state(
        fl: ->(state) {},
        fr: ->(state) { {value: state.value} }
      )

      assert_equal({value: 0}, decider.initial_state)
    end

    it "maps on decide" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide :increase, State do
          emit :increased
        end
      end

      decider = decider.dimap_on_state(
        fl: ->(state) { State.new(value: state[:value]) },
        fr: ->(state) { {value: state.value} }
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

      decider = decider.dimap_on_state(
        fl: ->(state) { State.new(value: state[:value]) },
        fr: ->(state) { {value: state.value} }
      )

      assert_equal({value: 1}, decider.evolve({value: 0}, :increased))
    end

    it "maps on terminal?" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        terminal? do
          state.value == 1
        end
      end

      decider = decider.dimap_on_state(
        fl: ->(state) { State.new(value: state[:value]) },
        fr: ->(state) {}
      )

      assert_equal(false, decider.terminal?({value: 0}))
      assert_equal(true, decider.terminal?({value: 1}))
    end
  end
end
