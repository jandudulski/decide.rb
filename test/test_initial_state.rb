# frozen_string_literal: true

require "test_helper"

class TestInitialState < Minitest::Test
  State = Data.define(:value)

  describe ".initial_state" do
    it "raises if initial state not defined" do
      assert_raises(Decider::StateNotDefined) do
        Decider.define
      end
    end

    it "raises if initial state already defined" do
      assert_raises(Decider::StateAlreadyDefined) do
        Decider.define do
          initial_state State.new(value: 1)
          initial_state State.new(value: 2)
        end
      end
    end
  end

  describe "#initial_state" do
    it "returns defined state" do
      decider = Decider.define do
        initial_state State.new(value: "value")
      end

      assert_equal decider.initial_state, State.new(value: "value")
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
        [left.initial_state, right.initial_state],
        composition.initial_state
      )
    end
  end
end
