# frozen_string_literal: true

require "test_helper"

class TestEvolve < Minitest::Spec
  State = Data.define(:value)
  Increased = Data.define(:value)
  Decreased = Data.define(:value)

  describe "#evolve" do
    it "returns state when event not defined" do
      decider = Decider.define do
        initial_state 0

        evolve Increased do
          state + event.value
        end
      end

      state = decider.initial_state

      assert_equal(
        state,
        decider.evolve(state, Decreased.new(value: 1))
      )
    end

    it "allows to define catch-all" do
      decider = Decider.define do
        initial_state 0

        evolve proc { true } do
          42
        end
      end

      state = decider.initial_state

      assert_equal(
        42,
        decider.evolve(state, Decreased.new(value: 1))
      )
    end

    it "evolves with a defined event" do
      decider = Decider.define do
        initial_state State.new(value: 5)

        evolve Increased do
          state.with(value: state.value + event.value)
        end

        evolve Decreased do
          state.with(value: state.value - event.value)
        end
      end

      assert_equal(
        State.new(value: 7),
        decider.evolve(decider.initial_state, Increased.new(value: 2))
      )

      assert_equal(
        State.new(value: 3),
        decider.evolve(decider.initial_state, Decreased.new(value: 2))
      )
    end

    it "evolves for state" do
      decider = Decider.define do
        initial_state 0

        evolve 0, Increased do
          1
        end

        evolve 1, Increased do
          2
        end

        evolve Increased do
          state + event.value
        end
      end

      assert_equal(
        1,
        decider.evolve(0, Increased.new(value: 123))
      )

      assert_equal(
        2,
        decider.evolve(1, Increased.new(value: 123))
      )

      assert_equal(
        42,
        decider.evolve(42, Increased.new(value: 0))
      )
    end

    it "can evolve with primitives" do
      decider = Decider.define do
        initial_state State.new(value: 5)

        evolve :increased do
          state.with(value: state.value + 1)
        end

        evolve :decreased do
          state.with(value: state.value - 1)
        end
      end

      assert_equal(
        State.new(value: 6),
        decider.evolve(decider.initial_state, :increased)
      )

      assert_equal(
        State.new(value: 4),
        decider.evolve(decider.initial_state, :decreased)
      )
    end

    it "can pattern match" do
      decider = Decider.define do
        initial_state State.new(value: 5)

        evolve proc { [state, event] in [State(value: 5), Increased(value: 1)] } do
          state.with(value: 0)
        end
      end

      assert_equal(
        State.new(value: 0),
        decider.evolve(decider.initial_state, Increased.new(value: 1))
      )
    end

    it "composes evolutions" do
      levent = Data.define

      left = Decider.define do
        initial_state nil

        evolve(levent) do
          :left
        end
      end

      revent = Data.define

      right = Decider.define do
        initial_state nil

        evolve(revent) do
          :right
        end
      end

      composition = Decider.compose(left, right)

      state = [
        Decider::Left.new(levent.new),
        Decider::Right.new(revent.new)
      ].reduce(composition.initial_state, &composition.method(:evolve))

      assert_equal(Decider::Pair.new(left: :left, right: :right), state)
    end

    it "provides proc for shortcut" do
      decider = Decider.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      assert_equal(
        2,
        [:increased, :increased].reduce(decider.initial_state, &decider.evolve)
      )
    end
  end
end
