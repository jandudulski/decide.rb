# frozen_string_literal: true

require "test_helper"

class TestViewDimapOnState < Minitest::Test
  State = Data.define(:value)

  describe ".dimap_on_state" do
    it "maps initial state" do
      view = Decider::View.define do
        initial_state State.new(value: 0)
      end

      view = Decider::View.dimap_on_state(
        ->(state) {},
        ->(state) { {value: state.value} },
        view
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

      view = Decider::View.dimap_on_state(
        ->(state) { State.new(value: state[:value]) },
        ->(state) { {value: state.value} },
        view
      )

      assert_equal({value: 1}, view.evolve({value: 0}, :increased))
    end
  end

  describe "#dimap_on_state" do
    it "maps initial state" do
      view = Decider::View.define do
        initial_state State.new(value: 0)
      end

      view = view.dimap_on_state(
        fl: ->(state) {},
        fr: ->(state) { {value: state.value} }
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

      view = view.dimap_on_state(
        fl: ->(state) { State.new(value: state[:value]) },
        fr: ->(state) { {value: state.value} }
      )

      assert_equal({value: 1}, view.evolve({value: 0}, :increased))
    end
  end
end
