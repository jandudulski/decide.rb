# frozen_string_literal: true

require "test_helper"

class TestViewLmapOnEvent < Minitest::Test
  State = Data.define(:value)

  describe ".lmap_on_event" do
    it "does not impact initial state" do
      view = Decider::View.define do
        initial_state 0
      end

      view = Decider::View.lmap_on_event(->(event) {}, view)

      assert_equal(0, view.initial_state)
    end

    it "maps on evolve" do
      view = Decider::View.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      view = Decider::View.lmap_on_event(->(event) { event.to_sym }, view)

      assert_equal(1, view.evolve(0, "increased"))
    end
  end

  describe "#lmap_on_event" do
    it "does not impact initial state" do
      view = Decider::View.define do
        initial_state 0
      end

      view = view.lmap_on_event(->(event) {})

      assert_equal(0, view.initial_state)
    end

    it "maps on evolve" do
      view = Decider::View.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      view = view.lmap_on_event(->(event) { event.to_sym })

      assert_equal(1, view.evolve(0, "increased"))
    end
  end
end
