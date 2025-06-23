# frozen_string_literal: true

require "test_helper"

class TestApply < Minitest::Test
  State = Data.define(:x, :y, :z)
  Increase = Data.define(:target)
  Increased = Data.define(:target)

  describe ".apply" do
    it "creates applicative" do
      fn = ->(sx, sy, sz) { State.new(x: sx, y: sy, z: sz) }

      dx = Decider.define do
        initial_state 0

        decide proc { command in Increase(target: :x) } do
          emit Increased.new(target: :x)
        end

        evolve proc { event in Increased(target: :x) } do
          state + 1
        end

        terminal? do
          state == 1
        end
      end

      dy = Decider.define do
        initial_state 0

        decide proc { command in Increase(target: :y) } do
          emit Increased.new(target: :y)
        end

        evolve proc { event in Increased(target: :y) } do
          state + 1
        end

        terminal? do
          state == 2
        end
      end

      dz = Decider.define do
        initial_state 0

        decide proc { command in Increase(target: :z) } do
          emit Increased.new(target: :z)
        end

        evolve proc { event in Increased(target: :z) } do
          state + 1
        end

        terminal? do
          state == 3
        end
      end

      decider = Decider.map(
        fn.curry, dx.lmap_on_state(->(state) { state.x })
      )
      decider = Decider.apply(
        decider, dy.lmap_on_state(->(state) { state.y })
      )
      decider = Decider.apply(
        decider, dz.lmap_on_state(->(state) { state.z })
      )

      assert_equal(State.new(x: 0, y: 0, z: 0), decider.initial_state)

      assert_equal(
        [Increased.new(target: :x)],
        decider.decide(Increase.new(target: :x), decider.initial_state)
      )
      assert_equal(
        [Increased.new(target: :y)],
        decider.decide(Increase.new(target: :y), decider.initial_state)
      )
      assert_equal(
        [Increased.new(target: :z)],
        decider.decide(Increase.new(target: :z), decider.initial_state)
      )

      assert_equal(
        State.new(x: 1, y: 0, z: 0),
        decider.evolve(decider.initial_state, Increased.new(target: :x))
      )
      assert_equal(
        State.new(x: 0, y: 1, z: 0),
        decider.evolve(decider.initial_state, Increased.new(target: :y))
      )
      assert_equal(
        State.new(x: 0, y: 0, z: 1),
        decider.evolve(decider.initial_state, Increased.new(target: :z))
      )

      refute decider.terminal?(State.new(x: 0, y: 0, z: 0))
      refute decider.terminal?(State.new(x: 1, y: 1, z: 1))
      refute decider.terminal?(State.new(x: 1, y: 2, z: 2))
      assert decider.terminal?(State.new(x: 1, y: 2, z: 3))
    end
  end

  describe "#apply" do
    it "creates applicative" do
      fn = ->(sx, sy, sz) { State.new(x: sx, y: sy, z: sz) }

      dx = Decider.define do
        initial_state 0

        decide proc { command in Increase(target: :x) } do
          emit Increased.new(target: :x)
        end

        evolve proc { event in Increased(target: :x) } do
          state + 1
        end

        terminal? do
          state == 1
        end
      end

      dy = Decider.define do
        initial_state 0

        decide proc { command in Increase(target: :y) } do
          emit Increased.new(target: :y)
        end

        evolve proc { event in Increased(target: :y) } do
          state + 1
        end

        terminal? do
          state == 2
        end
      end

      dz = Decider.define do
        initial_state 0

        decide proc { command in Increase(target: :z) } do
          emit Increased.new(target: :z)
        end

        evolve proc { event in Increased(target: :z) } do
          state + 1
        end

        terminal? do
          state == 3
        end
      end

      decider = dx.lmap_on_state(
        ->(state) { state.x }
      ).map(
        fn.curry
      ).apply(
        dy.lmap_on_state(->(state) { state.y })
      ).apply(
        dz.lmap_on_state(->(state) { state.z })
      )

      assert_equal(State.new(x: 0, y: 0, z: 0), decider.initial_state)

      assert_equal(
        [Increased.new(target: :x)],
        decider.decide(Increase.new(target: :x), decider.initial_state)
      )
      assert_equal(
        [Increased.new(target: :y)],
        decider.decide(Increase.new(target: :y), decider.initial_state)
      )
      assert_equal(
        [Increased.new(target: :z)],
        decider.decide(Increase.new(target: :z), decider.initial_state)
      )

      assert_equal(
        State.new(x: 1, y: 0, z: 0),
        decider.evolve(decider.initial_state, Increased.new(target: :x))
      )
      assert_equal(
        State.new(x: 0, y: 1, z: 0),
        decider.evolve(decider.initial_state, Increased.new(target: :y))
      )
      assert_equal(
        State.new(x: 0, y: 0, z: 1),
        decider.evolve(decider.initial_state, Increased.new(target: :z))
      )

      refute decider.terminal?(State.new(x: 0, y: 0, z: 0))
      refute decider.terminal?(State.new(x: 1, y: 1, z: 1))
      refute decider.terminal?(State.new(x: 1, y: 2, z: 2))
      assert decider.terminal?(State.new(x: 1, y: 2, z: 3))
    end
  end
end
