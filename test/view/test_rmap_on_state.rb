# frozen_string_literal: true

require "test_helper"

class TestViewRmapOnState < Minitest::Test
  State = Data.define(:value)

  describe ".rmap_on_state" do
    it "maps initial state" do
      view = Decider::View.define do
        initial_state State.new(value: 0)
      end

      view = Decider::View.rmap_on_state(
        ->(state) { {value: state.value} }, view
      )

      assert_equal({value: 0}, view.initial_state)
    end

    it "maps on evolve" do
      view = Decider::View.define do
        initial_state State.new(value: 0)

        evolve State, :increased do
          state.with(value: state.value + 1)
        end
      end

      view = Decider::View.rmap_on_state(
        ->(state) { {value: state.value} }, view
      )

      assert_equal({value: 1}, view.evolve(State.new(value: 0), :increased))
    end
  end

  describe "#rmap_on_state" do
    it "maps initial state" do
      view = Decider::View.define do
        initial_state State.new(value: 0)
      end

      view = view.rmap_on_state(->(state) { {value: state.value} })

      assert_equal({value: 0}, view.initial_state)
    end

    it "maps on evolve" do
      view = Decider::View.define do
        initial_state State.new(value: 0)

        evolve State, :increased do
          state.with(value: state.value + 1)
        end
      end

      view = view.rmap_on_state(->(state) { {value: state.value} })

      assert_equal({value: 1}, view.evolve(State.new(value: 0), :increased))
    end
  end
end
