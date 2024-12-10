# frozen_string_literal: true

require "test_helper"

class TestInitialState < Minitest::Test
  describe ".initial_state" do
    it "raises if initial state not defined" do
      assert_raises(Decider::StateNotDefined) do
        Decider.define
      end
    end

    it "raises if initial state already defined" do
      assert_raises(Decider::StateAlreadyDefined) do
        Decider.define do
          initial_state 0
          initial_state 1
        end
      end
    end
  end

  describe "#initial_state" do
    it "returns defined state" do
      decider = Decider.define do
        initial_state 0
      end

      assert_equal decider.initial_state, 0
    end

    it "returns composed initial states" do
      left = Decider.define do
        initial_state :left
      end

      right = Decider.define do
        initial_state :right
      end

      composition = Decider.compose(left, right)

      assert_equal(
        Decider::Pair.new(
          left: left.initial_state, right: right.initial_state
        ),
        composition.initial_state
      )
    end
  end
end
