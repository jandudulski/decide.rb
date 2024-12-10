# frozen_string_literal: true

require "test_helper"

class TestDecide < Minitest::Test
  Increase = Data.define(:value)
  Decrease = Data.define(:value)
  State = Data.define(:value)
  Result = Data.define(:value)

  describe "#decide" do
    it "returns empty list when nothing matches" do
      decider = Decider.define do
        initial_state 0

        decide Increase do
          [:increased]
        end
      end

      assert_equal(
        [],
        decider.decide(Decrease.new(value: 1), decider.initial_state)
      )
    end

    it "allows to define catch-all" do
      decider = Decider.define do
        initial_state 0

        decide Decrease, 1 do
          [:increased]
        end

        decide proc { true } do
          [:nothing]
        end
      end

      assert_equal(
        [:nothing],
        decider.decide(Decrease.new(value: 1), decider.initial_state)
      )
    end

    it "executes a defined command" do
      decider = Decider.define do
        initial_state 0

        decide Increase do
          [state + command.value]
        end

        decide Decrease do
          [state - command.value]
        end
      end

      assert_equal(
        [1],
        decider.decide(Increase.new(value: 1), decider.initial_state)
      )

      assert_equal(
        [-1],
        decider.decide(Decrease.new(value: 1), decider.initial_state)
      )
    end

    it "can match just a command" do
      decider = Decider.define do
        initial_state 0

        decide Increase do
          [command.value]
        end
      end

      assert_equal(
        [1],
        decider.decide(Increase.new(value: 1), decider.initial_state)
      )
    end

    it "can match command and state" do
      decider = Decider.define do
        initial_state 0

        decide Increase, 0 do
          [command.value]
        end

        decide Increase, 1 do
          [42]
        end
      end

      assert_equal(
        [1],
        decider.decide(Increase.new(value: 1), decider.initial_state)
      )

      assert_equal(
        [42],
        decider.decide(Increase.new(value: 1), 1)
      )
    end

    it "can pattern match" do
      decider = Decider.define do
        initial_state State.new(value: 0)

        decide proc { [command, state] in [Increase(value:), State(value: ^value)] } do
          [42]
        end

        decide Increase, State do
          [1]
        end

        decide proc { command in Decrease(value: 2) } do
          [command.value]
        end
      end

      assert_equal(
        [1],
        decider.decide(Increase.new(value: 1), decider.initial_state)
      )

      assert_equal(
        [2],
        decider.decide(Decrease.new(value: 2), decider.initial_state)
      )

      assert_equal(
        [42],
        decider.decide(Increase.new(value: 3), State.new(value: 3))
      )
    end

    it "accepts primitive commands" do
      decider = Decider.define do
        initial_state 0

        decide :increase, 0 do
          [5]
        end

        decide :increase, 1 do
          [10]
        end
      end

      assert_equal(
        [5],
        decider.decide(:increase, decider.initial_state)
      )

      assert_equal(
        [10],
        decider.decide(:increase, 1)
      )
    end

    it "composes decisions" do
      lcommand = Data.define

      left = Decider.define do
        initial_state 0

        decide(lcommand) do
          [:levent]
        end
      end

      rcommand = Data.define

      right = Decider.define do
        initial_state 0

        decide(rcommand) do
          [:revent]
        end
      end

      composition = Decider.compose(left, right)

      assert_equal(
        [Decider::Left.new(:levent)],
        composition.decide(Decider::Left.new(lcommand.new), composition.initial_state)
      )

      assert_equal(
        [Decider::Right.new(:revent)],
        composition.decide(Decider::Right.new(rcommand.new), composition.initial_state)
      )
    end
  end
end
