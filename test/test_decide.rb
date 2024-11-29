# frozen_string_literal: true

require "test_helper"

class TestDecide < Minitest::Test
  Increase = Data.define
  Decrease = Data.define

  describe "#decide" do
    it "returns empty list when command not defined" do
      decider = Decider.define do
        initial_state 0

        decide Increase do |_command, _state|
          [:increased]
        end
      end

      assert_equal(
        [],
        decider.decide(Decrease.new, decider.initial_state)
      )
    end

    it "executes a defined command" do
      decider = Decider.define do
        initial_state 0

        decide Increase do |command, state|
          [:increased]
        end

        decide Decrease do |command, state|
          [:decreased]
        end
      end

      assert_equal(
        [:increased],
        decider.decide(Increase.new, decider.initial_state)
      )

      assert_equal(
        [:decreased],
        decider.decide(Decrease.new, decider.initial_state)
      )
    end

    it "accepts primitive commands" do
      decider = Decider.define do
        initial_state 0

        decide :increase do |command, state|
          [:increased]
        end
      end

      assert_equal(
        [:increased],
        decider.decide(:increase, decider.initial_state)
      )
    end
  end

  describe "#decide!" do
    it "accepts primitive commands" do
      decider = Decider.define do
        initial_state 0

        decide :increase do |command, state|
          [:increased]
        end
      end

      assert_equal(
        [:increased],
        decider.decide!(:increase, decider.initial_state)
      )
    end

    it "raises when command not defined" do
      decider = Decider.define do
        initial_state 0

        decide Increase do |command, state|
          [:increased]
        end
      end

      assert_raises(ArgumentError, "Unknown command: TestDecider::Increase") do
        decider.decide!(Decrease.new, decider.initial_state)
      end
    end
  end
end
