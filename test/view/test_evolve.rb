# frozen_string_literal: true

require "test_helper"

class TestViewEvolve < Minitest::Spec
  State = Data.define(:value)
  Increased = Data.define(:value)
  Decreased = Data.define(:value)

  describe "#evolve" do
    it "returns state when event not defined" do
      view = Decider::View.define do
        initial_state 0

        evolve Increased do
          state + event.value
        end
      end

      state = view.initial_state

      assert_equal(
        state,
        view.evolve(state, Decreased.new(value: 1))
      )
    end

    it "allows to define catch-all" do
      view = Decider::View.define do
        initial_state 0

        evolve proc { true } do
          42
        end
      end

      state = view.initial_state

      assert_equal(
        42,
        view.evolve(state, Decreased.new(value: 1))
      )
    end

    it "evolves with a defined event" do
      view = Decider::View.define do
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
        view.evolve(view.initial_state, Increased.new(value: 2))
      )

      assert_equal(
        State.new(value: 3),
        view.evolve(view.initial_state, Decreased.new(value: 2))
      )
    end

    it "evolves for state" do
      view = Decider::View.define do
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
        view.evolve(0, Increased.new(value: 123))
      )

      assert_equal(
        2,
        view.evolve(1, Increased.new(value: 123))
      )

      assert_equal(
        42,
        view.evolve(42, Increased.new(value: 0))
      )
    end

    it "can evolve with primitives" do
      view = Decider::View.define do
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
        view.evolve(view.initial_state, :increased)
      )

      assert_equal(
        State.new(value: 4),
        view.evolve(view.initial_state, :decreased)
      )
    end

    it "can pattern match" do
      view = Decider::View.define do
        initial_state State.new(value: 5)

        evolve proc { [state, event] in [State(value: 5), Increased(value: 1)] } do
          state.with(value: 0)
        end
      end

      assert_equal(
        State.new(value: 0),
        view.evolve(view.initial_state, Increased.new(value: 1))
      )
    end

    it "provides proc for shortcut" do
      view = Decider::View.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      assert_equal(
        2,
        [:increased, :increased].reduce(view.initial_state, &view.evolve)
      )
    end
  end
end
