# frozen_string_literal: true

require "test_helper"

class TestViewMany < Minitest::Test
  State = Data.define(:value)

  describe ".many" do
    it "returns empty hash for initial state" do
      view = Decider::View.define do
        initial_state 0
      end

      views = Decider::View.many(view)

      assert_equal({}, views.initial_state)
    end

    it "evolves per id" do
      view = Decider::View.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      views = Decider::View.many(view)

      assert_equal(
        {42 => 1}, views.evolve(views.initial_state, [42, :increased])
      )
      assert_equal(
        {42 => 3, 102 => 1}, views.evolve({42 => 2, 102 => 1}, [42, :increased])
      )
    end
  end

  describe "#many" do
    it "returns empty hash for initial state" do
      view = Decider::View.define do
        initial_state 0
      end

      assert_equal({}, view.many.initial_state)
    end

    it "evolves per id" do
      view = Decider::View.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      views = view.many

      assert_equal(
        {42 => 1}, views.evolve(views.initial_state, [42, :increased])
      )
      assert_equal(
        {42 => 3, 102 => 1}, views.evolve({42 => 2, 102 => 1}, [42, :increased])
      )
    end
  end
end
