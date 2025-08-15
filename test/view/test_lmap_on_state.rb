# frozen_string_literal: true

require "test_helper"

class TestViewLmapOnState < Minitest::Test
  State = Data.define(:value)

  describe ".lmap_on_state" do
    it "does not impact initial state" do
      view = Decider::View.define do
        initial_state State.new(value: 0)
      end

      view = Decider::View.lmap_on_state(->(state) {}, view)

      assert_equal(State.new(value: 0), view.initial_state)
    end

    it "maps on evolve" do
      view = Decider::View.define do
        initial_state State.new(value: 0)

        evolve State, :increased do
          state.with(value: state.value + 1)
        end
      end

      view = Decider::View.lmap_on_state(
        ->(state) { State.new(value: state[:value]) }, view
      )

      assert_equal(State.new(value: 1), view.evolve({value: 0}, :increased))
    end
  end

  describe "#lmap_on_state" do
    it "does not impact initial state" do
      view = Decider::View.define do
        initial_state State.new(value: 0)
      end

      view = view.lmap_on_state(->(state) {})

      assert_equal(State.new(value: 0), view.initial_state)
    end

    it "maps on evolve" do
      view = Decider::View.define do
        initial_state State.new(value: 0)

        evolve State, :increased do
          state.with(value: state.value + 1)
        end
      end

      view = view.lmap_on_state(
        ->(state) { State.new(value: state[:value]) }
      )

      assert_equal(State.new(value: 1), view.evolve({value: 0}, :increased))
    end
  end
end
