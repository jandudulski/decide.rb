# frozen_string_literal: true

require "test_helper"

class TestMany < Minitest::Test
  State = Data.define(:value)

  describe ".many" do
    it "returns empty hash for initial state" do
      decider = Decider.define do
        initial_state 0
      end

      deciders = Decider.many(decider)

      assert_equal({}, deciders.initial_state)
    end

    it "decides on id" do
      decider = Decider.define do
        initial_state 0

        decide :command, 0 do
          emit :zero
        end

        decide :command, 1 do
          emit :one
        end
      end

      deciders = Decider.many(decider)

      assert_equal(
        [[42, :zero]], deciders.decide([42, :command], deciders.initial_state)
      )
      assert_equal(
        [[42, :one]], deciders.decide([42, :command], {42 => 1})
      )
    end

    it "evolves per id" do
      decider = Decider.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      deciders = Decider.many(decider)

      assert_equal(
        {42 => 1}, deciders.evolve(deciders.initial_state, [42, :increased])
      )
      assert_equal(
        {42 => 3, 102 => 1}, deciders.evolve({42 => 2, 102 => 1}, [42, :increased])
      )
    end

    it "terminal on all ids" do
      decider = Decider.define do
        initial_state 0

        terminal? do
          state == 1
        end
      end

      deciders = Decider.many(decider)

      refute(deciders.terminal?(deciders.initial_state))
      refute(deciders.terminal?({42 => 1, 43 => 2}))
      assert(deciders.terminal?({42 => 1, 43 => 1}))
    end
  end

  describe "#many" do
    it "returns empty hash for initial state" do
      decider = Decider.define do
        initial_state 0
      end

      assert_equal({}, decider.many.initial_state)
    end

    it "decides on id" do
      decider = Decider.define do
        initial_state 0

        decide :command, 0 do
          emit :zero
        end

        decide :command, 1 do
          emit :one
        end
      end

      deciders = decider.many

      assert_equal(
        [[42, :zero]], deciders.decide([42, :command], deciders.initial_state)
      )
      assert_equal(
        [[42, :one]], deciders.decide([42, :command], {42 => 1})
      )
    end

    it "evolves per id" do
      decider = Decider.define do
        initial_state 0

        evolve :increased do
          state + 1
        end
      end

      deciders = decider.many

      assert_equal(
        {42 => 1}, deciders.evolve(deciders.initial_state, [42, :increased])
      )
      assert_equal(
        {42 => 3, 102 => 1}, deciders.evolve({42 => 2, 102 => 1}, [42, :increased])
      )
    end

    it "terminal on all ids" do
      decider = Decider.define do
        initial_state 0

        terminal? do
          state == 1
        end
      end

      deciders = decider.many

      refute(deciders.terminal?(deciders.initial_state))
      refute(deciders.terminal?({42 => 1, 43 => 2}))
      assert(deciders.terminal?({42 => 1, 43 => 1}))
    end
  end
end
